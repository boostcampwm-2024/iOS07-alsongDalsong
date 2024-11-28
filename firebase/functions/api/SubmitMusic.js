// TODO : 음악제출 API입니다.
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
module.exports.submitMusic = onRequest({ region: 'asia-southeast1' }, async (req, res) => {
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
    const currentAnswer = roomData.answers.length;
    const playersCount = roomData.players.length;
    if (!userData) {
      return res.status(404).json({ error: 'plyer Data not found' });
    }
    const currentMode = roomData.mode;
    switch (currentMode) {
      case 'humming':
        const currentTime = new Date();
        const dueTime = new Date(currentTime.getTime() + 1 * 60 * 1000);

        if (!req.body) {
          const answer = {
            player: userData,
          };
          await roomRef.update({
            round: 1,
            answers: FieldValue.arrayUnion(answer),
            dueTime: dueTime,
          });
          break;
        }

        const answer = {
          player: userData,
          music: req.body,
        };
        // 모든 사람이 제출했을 때
        if (currentAnswer + 1 === playersCount) {
          await roomRef.update({
            round: 1,
            answers: FieldValue.arrayUnion(answer),
            dueTime: dueTime,
          });
        } else {
          await roomRef.update({
            answers: FieldValue.arrayUnion(answer),
          });
        }
        break;
      default:
        console.log('잘못된 모드');
        break;
    }

    res.status(200).json({ status: 'success' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to create room' });
  }
});
