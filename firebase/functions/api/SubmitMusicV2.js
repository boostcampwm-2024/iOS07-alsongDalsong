const { FieldValue } = require('firebase-admin/firestore');
const { onRequest } = require('firebase-functions/v2/https');
const admin = require('../FirebaseAdmin.js');

module.exports.submitMusicV2 = onRequest({ region: 'asia-southeast1' }, async (req, res) => {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Only POST requests are accepted' });
  }

  const { userId, roomNumber } = req.query;
  if (!userId) {
    console.log('유저 아이디 없음');
    return res.status(400).json({ error: 'User ID is required' });
  }
  if (!roomNumber) {
    console.log('방 번호 없음');
    return res.status(400).json({ error: 'Room Number is required' });
  }

  try {
    const roomRef = admin.firestore().collection('rooms').doc(roomNumber);

    await admin.firestore().runTransaction(async (transaction) => {
      const roomSnapshot = await transaction.get(roomRef);
      const roomData = roomSnapshot.data();
      const userData = roomData.players.find((player) => player.id === userId);

      if (!userData) {
        throw new Error('Player data not found');
      }

      const currentAnswer = roomData.answers.length;
      const playersCount = roomData.players.length;

      const currentMode = roomData.mode;
      switch (currentMode) {
        case 'humming':
          const currentTime = new Date();
          const dueTime = new Date(currentTime.getTime() + 1 * 60 * 1000);

          let answer;
          if (!req.body) {
            answer = {
              player: userData,
            };
          } else {
            answer = {
              player: userData,
              music: req.body,
            };
          }

          // 이미 제출한 사용자인지 확인
          const hasSubmitted = roomData.answers.some((ans) => ans.player.id === userId);
          if (hasSubmitted) {
            throw new Error('User has already submitted');
          }

          // 답변 추가
          transaction.update(roomRef, {
            answers: FieldValue.arrayUnion(answer),
          });

          // 모든 사용자가 제출했는지 확인
          if (currentAnswer + 1 === playersCount) {
            transaction.update(roomRef, {
              round: 1,
              dueTime: dueTime,
            });
          }
          break;
        default:
          console.log('잘못된 모드');
          break;
      }
    });

    res.status(200).json({ status: 'success' });
  } catch (error) {
    console.error('Error submitting music:', error);
    res.status(500).json({ error: error.message });
  }
});
