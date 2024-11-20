// TODO : 방 생성 API입니다.
// fireStore database의 rooms/{roomNumber} 에 room 데이터를 생성합니다.

const { onRequest } = require('firebase-functions/v2/https');
const { generateRoomNumber, getUserData, createRoomData } = require('../common/RoomHelper.js');
const admin = require('../FirebaseAdmin.js');

/**
 * 방 생성을 요청하는 API
 * @param playerId - 호스트 id
 * @returns roomNumber - 생성된 방 번호
 */

module.exports.createRoom = onRequest({ region: 'asia-southeast1' }, async (req, res) => {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Only POST requests are accepted' });
  }

  const { hostID } = req.body;
  if (!hostID) {
    return res.status(400).json({ error: 'Host ID is required' });
  }

  try {
    const roomNumber = await generateRoomNumber();
    const hostData = await getUserData(hostID);

    if (!hostData) {
      return res.status(404).json({ error: 'Host not found' });
    }

    const roomData = createRoomData(roomNumber, hostData);
    await admin.firestore().collection('rooms').doc(roomNumber).set(roomData);

    res.status(200).json({ number: roomNumber });
  } catch (error) {
    res.status(500).json({ error: 'Failed to create room' });
  }
});
