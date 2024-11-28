// TODO : 정답 제출 API입니다.
// fireStore database의 rooms/{roomNumber} 에 room 데이터를 생성합니다.
const { FieldValue } = require('firebase-admin/firestore');
const { onRequest } = require('firebase-functions/v2/https');
const { getUserData } = require('../common/RoomHelper.js');
const admin = require('../FirebaseAdmin.js');
/**
 * 방 생성을 요청하는 API
 * @param playerId - 호스트 id
 * @returns roomNumber - 생성된 방 번호
 */
module.exports.submitAnswer = onRequest({ region: 'asia-southeast1' }, async (req, res) => {
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
    const roomSnapshot = await roomRef.get();
    const roomData = roomSnapshot.data();
    const userData = roomData.players.find((player) => player.id === userId);
    const playersCount = roomData.players.length;
    const submitCount = roomData.submits.length;
    if (!userData) {
      return res.status(404).json({ error: 'plyer Data not found' });
    }
    const answer = {
      player: userData,
      music: req.body,
    };
    if (submitCount + 1 === playersCount) {
      await roomRef.update({
        submits: FieldValue.arrayUnion(answer),
        status: 'result',
      });
    } else {
      await roomRef.update({
        submits: FieldValue.arrayUnion(answer),
      });
    }

    res.status(200).json({ status: 'success' });
  } catch (error) {
    console.log('에러러', error);
    res.status(500).json({ error: 'Failed to create room' });
  }
});
