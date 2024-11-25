// TODO : 모드 변경 API 입니다.
// fireStore database의 rooms/{roomNumber}/mode를 업데이트 합니다.

const { onRequest } = require('firebase-functions/v2/https');
const { getUserData } = require('../common/RoomHelper.js');
const admin = require('../FirebaseAdmin.js');

/**
 * 방 참여를 요청하는 API
 * @param roomNumber - 방 번호
 * @param playerId - 참여자 id
 * @param mode - 게임 모드
 * @returns playerData
 */
module.exports.changeMode = onRequest({ region: 'asia-southeast1' }, async (req, res) => {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Only POST requests are accepted' });
  }
  const { roomNumber, userId, mode } = req.body;

  if (!roomNumber || !userId || !mode) {
    return res.status(400).json({ error: 'Room number, user ID, mode are required' });
  }

  try {
    const roomRef = admin.firestore().collection('rooms').doc(roomNumber);
    const roomSnapshot = await roomRef.get();

    if (!roomSnapshot.exists) {
      return res.status(404).json({ error: 'Room not found' });
    }

    const roomData = roomSnapshot.data();

    if (roomData.host === userId) {
      return res.status(400).json({ error: 'is not host' });
    }

    const userData = await getUserData(userId);
    if (!userData) {
      return res.status(404).json({ error: 'User not found' });
    }

    const validModes = ['humming', 'harmony', 'sync', 'instant', 'tts'];
    if (!validModes.includes(mode)) {
      return res.status(400).json({ error: 'Invalid mode' });
    }

    await roomRef.update({
      mode: mode,
    });

    res.status(200).json({ success: true });
  } catch (error) {
    console.error('Join room error:', error);
    res.status(500).json({ error: 'Failed to join room' });
  }
});
