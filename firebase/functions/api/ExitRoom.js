// TODO: 방 나가기 로직 구현
// 만약 호스트가 나간 경우 players중 남은 사람 중 랜덤으로 호스트를 지정한다.
// 방에 남은 사람이 없을 경우 방을 삭제 한다.

const { onRequest } = require('firebase-functions/v2/https');
const { getUserData } = require('../common/RoomHelper.js');
const admin = require('../FirebaseAdmin.js');
/**
 * 방 나가기를 요청하는 API
 * @param roomNumber - 방 번호
 * @param playerId - 나가는 참여자 id
 */

module.exports.exitRoom = onRequest({ region: 'asia-southeast1' }, async (req, res) => {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Only POST requests are accepted' });
  }

  const { roomNumber, userId } = req.body;
  if (!roomNumber || !userId) {
    return res.status(400).json({ error: 'Room number and user ID are required' });
  }

  try {
    const roomRef = admin.firestore().collection('rooms').doc(roomNumber);
    const roomData = await roomRef.get();
    const players = roomData.data().players;

    if (!roomData.exists) {
      return res.status(404).json({ error: 'Room not found' });
    }

    if (roomData.data().host.id === userId) {
      if (players.length > 1) {
        const newHost = players.find((player) => player.id !== userId);
        await roomRef.update({
          host: newHost,
          players: players.filter((player) => player.id !== userId),
        });
      } else {
        await roomRef.delete();
      }
    } else {
      const updatedPlayers = players.filter((player) => player.id !== userId);
      await roomRef.update({
        players: updatedPlayers,
      });
    }
    res.status(200).json({ message: 'Successfully exited the room' });
  } catch (error) {
    console.error('Exit room error:', error);
    res.status(500).json({ error: 'Failed to exit room' });
  }
});
