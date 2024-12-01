// TODO : 방 참여 API입니다.
// fireStore database의 rooms/{roomNumber}/players 에 player 데이터를 추가합니다.

const { onRequest } = require('firebase-functions/v2/https');
const { getUserData } = require('../common/RoomHelper.js');
const admin = require('../FirebaseAdmin.js');
const { FieldValue } = require('firebase-admin/firestore');

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

  try {
    const roomRef = admin.firestore().collection('rooms').doc(roomNumber);
    const roomSnapshot = await roomRef.get();

    if (!roomSnapshot.exists) {
      return res.status(404).json({ error: 'Room not found' });
    }

    const roomData = roomSnapshot.data();
    const playerExists = roomData.players.some((player) => player.id === userId);
    const inGame = roomData.status !== null;

    if (inGame) {
      return res.status(452).json({ error: 'Game has already started in this room' });

    if (playerExists) {
      return res.status(400).json({ error: 'User already in the room' });
    }

    const userData = await getUserData(userId);
    if (!userData) {
      return res.status(404).json({ error: 'User not found' });
    }

    const player = {
      id: userId,
      avatarUrl: userData.avatarUrl || '',
      nickname: userData.nickname || '',
      score: userData.score || 0,
      order: 0,
    };

    await roomRef.update({
      players: FieldValue.arrayUnion(player),
    });

    res.status(200).json({ number: roomNumber });
  } catch (error) {
    console.error('Join room error:', error);
    res.status(500).json({ error: 'Failed to join room' });
  }
});
