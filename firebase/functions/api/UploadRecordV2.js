// TODO: 녹음파일을 업로드하는 API입니다.
// Stroage에 파일을 저장하고, 해당 URL을 rooms/{RoomID}/records 컬렉션에 저장합니다.

const { onRequest } = require('firebase-functions/v2/https');
const admin = require('../FirebaseAdmin.js');
const { v4: uuidv4 } = require('uuid');
const { FieldValue } = require('firebase-admin/firestore');
const express = require('express');
const { Readable } = require('stream');
const cors = require('cors');
const bodyParser = require('body-parser');
const fileParser = require('express-multipart-file-parser');

const app = express();
app.use(fileParser);
app.use(cors({ origin: true }));
app.use(bodyParser.urlencoded({ extended: true }));

app.post('/v2-uploadRecording', async (req, res) => {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Only POST requests are accepted' });
  }

  const { roomNumber, userId } = req.query;

  if (!roomNumber || !userId) {
    return res.status(400).json({ error: 'Room number and user ID are required' });
  }

  const file = req.files[0];

  if (!file) {
    return res.status(400).json({ error: 'File is required' });
  }

  console.log('Received file:', file);

  try {
    const storage = admin.storage().bucket();
    const uuid = uuidv4();
    const fileName = `audios/${uuid}_${file.originalname}`;
    const fileUpload = storage.file(fileName);

    const fileStream = Readable.from(file.buffer);
    const writeStream = fileUpload.createWriteStream({
      metadata: {
        contentType: file.mimetype,
      },
    });

    // 파일 업로드를 Promise로 처리
    await new Promise((resolve, reject) => {
      fileStream.pipe(writeStream).on('finish', resolve).on('error', reject);
    });

    // 파일에 대한 공개 URL 생성
    await fileUpload.makePublic();
    const publicUrl = `https://storage.googleapis.com/${storage.name}/${fileName}`;

    const roomRef = admin.firestore().collection('rooms').doc(roomNumber);

    // 트랜잭션 시작
    await admin.firestore().runTransaction(async (transaction) => {
      const roomSnapshot = await transaction.get(roomRef);
      const roomData = roomSnapshot.data();

      const playerExists = roomData.players.some((player) => player.id === userId);

      if (!playerExists) {
        throw new Error('User not in the room');
      }

      const userData = roomData.players.find((player) => player.id === userId);

      if (!userData) {
        throw new Error('User not found');
      }

      const playersCount = roomData.players.length;
      const currentRound = roomData.round || 0;
      const currentOrderRecord = roomData.recordOrder || 0;
      const currentMode = roomData.mode;
      const currentAnswer = roomData.answers;
      const currentAnswersCount = currentAnswer.length;

      // 현재 라운드의 녹음 데이터를 필터링
      const currentRoundRecords = roomData.records
        ? roomData.records.filter((record) => record.recordOrder === currentOrderRecord)
        : [];

      console.log('-------------------------------------');
      console.log(`현재 라운드: ${currentRound}`);
      console.log(`현재 라운드 녹음 수: ${currentRoundRecords.length}`);
      console.log(`플레이어 수: ${playersCount}`);
      console.log(`현재 모드: ${currentMode}`);
      console.log(`현재 OrderRecord: ${currentOrderRecord}`);
      console.log(`현재 라운드(OrderRecord) 녹음: ${currentRoundRecords.length}`);
      console.log(`현재 Answer 수: ${currentAnswersCount}`);
      console.log(`현재 Answer: ${currentAnswer}`);
      console.log('-------------------------------------');

      switch (currentMode) {
        case 'humming':
          const currentTime = new Date();
          const dueTime = new Date(currentTime.getTime() + 1 * 60 * 1000);

          const record = {
            player: userData,
            recordOrder: currentOrderRecord,
            fileUrl: publicUrl,
          };

          // 이미 제출한 사용자인지 확인
          const hasSubmitted = currentRoundRecords.some((rec) => rec.player.id === userId);

          if (hasSubmitted) {
            throw new Error('User has already submitted');
          }

          // 녹음 데이터 추가
          transaction.update(roomRef, {
            records: FieldValue.arrayUnion(record),
          });

          // 모든 사용자가 제출했는지 확인
          if (currentRoundRecords.length + 1 === playersCount) {
            transaction.update(roomRef, {
              recordOrder: currentOrderRecord + 1,
              status: 'rehumming',
              dueTime: dueTime,
            });
          }
          break;
        default:
          console.log('Invalid mode');
          throw new Error('Invalid mode');
      }
    });

    res.status(200).send({ success: true });
  } catch (error) {
    console.error('Error during file upload or Firestore transaction:', error);
    return res.status(500).json({ error: error.message });
  }
});

// Cloud Function 내보내기
module.exports.uploadRecordingV2 = onRequest({ region: 'asia-southeast1' }, app);
