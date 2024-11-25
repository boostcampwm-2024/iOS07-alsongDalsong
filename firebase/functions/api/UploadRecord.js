// TODO: 녹음파일을 업로드하는 API입니다.
// Stroage에 파일을 저장하고, 해당 URL을 rooms/{RoomID}/Record Record 타입으로 저장합니다.

const { onRequest } = require('firebase-functions/v2/https');
const admin = require('../FirebaseAdmin.js');
const { v4: uuidv4 } = require('uuid');
const { FieldValue } = require('firebase-admin/firestore');
const { getUserData } = require('../common/RoomHelper.js');

/**
 * 음성 파일을 업로드 하는 API 입니다.
 * https://SERVER_URL/uploadrecording/?roomNumber={roomNumber}&userId={userId}}
 * @param roomNumber - 방 정보
 * @param userId - 호스트 id
 * @param round - 라운드
 * @param file - 업로드 파일
 * @returns roomData
 */
const express = require('express');
const { Readable } = require('stream');
const cors = require('cors');
const bodyParser = require('body-parser');
const fileParser = require('express-multipart-file-parser');

const app = express();
app.use(fileParser);
app.use(cors({ origin: true }));
app.use(bodyParser.urlencoded({ extended: true }));

// 파일 업로드 엔드포인트
app.post('/uploadrecording', async (req, res) => {
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

    fileStream.pipe(writeStream);

    writeStream.on('error', (err) => {
      console.error('File upload error:', err);
      return res.status(500).json({ error: 'Failed to upload file' });
    });

    writeStream.on('finish', async () => {
      try {
        // 파일에 대한 공개 URL 생성
        await fileUpload.makePublic();
        publicUrl = `https://storage.googleapis.com/${storage.name}/${fileName}`;

        const roomRef = admin.firestore().collection('rooms').doc(roomNumber);
        const roomSnapshot = await roomRef.get();

        if (!roomSnapshot.exists) {
          return res.status(404).json({ error: 'Room not found' });
        }

        const roomData = roomSnapshot.data();
        const playerExists = roomData.players.some((player) => player.id === userId);

        if (!playerExists) {
          return res.status(400).json({ error: 'User not in the room' });
        }

        const userData = await getUserData(userId);
        if (!userData) {
          return res.status(404).json({ error: 'User not found' });
        }

        // Firestore에 저장
        const record = {
          player: userData,
          round: roomData.round,
          fileUrl: publicUrl,
        };

        await roomRef.update({
          records: FieldValue.arrayUnion(record),
        });

        res.status(200).send({ success: true, url: publicUrl });
      } catch (error) {
        console.error('Error after file upload:', error);
        return res.status(500).json({ error: 'Failed to process file' });
      }
    });
  } catch (error) {
    console.error('Upload record error:', error);
    return res.status(500).json({ error: 'Failed to upload file' });
  }
});

// Cloud Function 내보내기
module.exports.uploadRecord = onRequest({ region: 'asia-southeast1' }, app);
