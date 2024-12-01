// TODO : 정답 제출 API입니다.
// fireStore database의 rooms/{roomNumber} 에 room 데이터를 생성합니다.
const { FieldValue } = require('firebase-admin/firestore');
const { onRequest } = require('firebase-functions/v2/https');
const admin = require('../FirebaseAdmin.js');

/**
 * 정답 제출을 처리하는 API
 * @param userId - 사용자 ID
 * @param roomNumber - 방 번호
 * @returns 상태 메시지
 */
module.exports.submitAnswerV2 = onRequest({ region: 'asia-southeast1' }, async (req, res) => {
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

    // 트랜잭션 시작
    await admin.firestore().runTransaction(async (transaction) => {
      const roomSnapshot = await transaction.get(roomRef);
      const roomData = roomSnapshot.data();

      if (!roomData) {
        throw new Error('Room not found');
      }

      const userData = roomData.players.find((player) => player.id === userId);

      if (!userData) {
        throw new Error('Player data not found');
      }

      const playersCount = roomData.players.length;
      const submitCount = roomData.submits ? roomData.submits.length : 0;

      // 이미 제출한 사용자인지 확인
      const hasSubmitted = roomData.submits ? roomData.submits.some((submit) => submit.player.id === userId) : false;

      if (hasSubmitted) {
        throw new Error('User has already submitted an answer');
      }

      const answer = {
        player: userData,
        music: req.body,
      };

      // 제출 업데이트
      transaction.update(roomRef, {
        submits: FieldValue.arrayUnion(answer),
      });

      // 모든 플레이어가 제출했는지 확인
      if (submitCount + 1 === playersCount) {
        transaction.update(roomRef, {
          status: 'result',
        });
      }
    });

    res.status(200).json({ status: 'success' });
  } catch (error) {
    console.error('에러 발생:', error);
    res.status(500).json({ error: error.message });
  }
});
