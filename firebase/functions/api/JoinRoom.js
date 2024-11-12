// TODO : 방 참여 API입니다.
// fireStore database의 rooms/{roomNumber}/players 에 player 데이터를 추가합니다.

const { onRequest } = require('firebase-functions/v2/https');
const admin = require('../FirebaseAdmin.js');

/**
 * 방 참여를 요청하는 API
 * @param roomNumber - 방 번호
 * @param playerId - 참여자 id
 * @returns playerData
 */
module.exports.joinRoom = onRequest({ region: 'asia-southeast1' }, async (req, res) => {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Only POST requests are accepted' });
  }

  const { roomNumber, userId } = req.body;
  if (!roomNumber || !userId) {
    return res.status(400).json({ error: 'Room number and user ID are required' });
  }

  const roomRef = admin.firestore().collection('rooms').doc(roomNumber);
  try {
    const roomSnapshot = await roomRef.get();
    if (!roomSnapshot.exists) {
      return res.status(404).json({ error: 'Room not found' });
    }

    const roomData = roomSnapshot.data();
    const playerExists = roomData.players.some((player) => player.id === userId);

    if (playerExists) {
      return res.status(400).json({ error: 'User already in the room' });
    }

    const userData = await getUserData(userId);
    if (!userData) {
      return res.status(404).json({ error: 'User not found' });
    }

    const player = {
      id: userData.id,
      avatar: userData.avatar,
      nickname: userData.nickname,
      score: userData.score,
      order: 0,
    };

    await roomRef.update({
      players: FieldValue.arrayUnion(player),
    });

    const updatedRoomData = (await roomRef.get()).data();
    res.status(200).json(updatedRoomData);
  } catch (error) {
    logger.error('Error joining room:', error);
    res.status(500).json({ error: 'Failed to join room' });
  }
});
