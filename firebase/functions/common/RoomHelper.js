const admin = require('../FirebaseAdmin.js');
const firestore = admin.firestore();
/**
 *
 * @param {*} roomNumber
 * @param {*} hostData
 * @returns roomData
 */
function createRoomData(roomNumber, hostData) {
  const host = {
    id: hostData.id,
    avatarUrl: hostData.avatarUrl || '',
    nickname: hostData.nickname || '',
    score: hostData.score || 0,
    order: 0,
  };

  return {
    number: roomNumber,
    host: host,
    players: [],
    mode: 'humming',
    round: 0,
    status: null,
    records: [],
    answers: [],
    dueTime: null,
    selectedRecords: [],
    submits: [],
    recordOrder: null,
  };
}

/**
 * 방 번호를 생성하는 함수.
 * @returns roomNumber
 */
async function generateRoomNumber() {
  const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  let roomNumber;
  let roomExists = true;

  while (roomExists) {
    roomNumber = Array.from({ length: 6 }, () => characters.charAt(Math.floor(Math.random() * characters.length))).join(
      ''
    );
    roomExists = await invalidRoomNumber(roomNumber);
  }

  return roomNumber;
}

/**
 * 방 번호가 유효한지 확인하는 함수
 * @param roomNumber - 방 번호
 * @returns boolean
 */
async function invalidRoomNumber(roomNumber) {
  const roomSnapshot = await firestore.collection('rooms').doc(roomNumber).get();
  return roomSnapshot.exists;
}

/**
 * Realtime Database에 있는 Player 데이터 가져오는 함수
 * @param id - 사용자 id
 * @returns player
 */

async function getUserData(id) {
  const userSnapshot = await admin.database().ref(`/players/${id}`).once('value');
  if (!userSnapshot.exists()) return null;
  return userSnapshot.val();
}

/**
 * 방의 정원을 확인하는 함수
 * @param roomNumber - 방 번호
 * @returns boolean
 */
async function isRoomFull(roomNumber) {
  const roomSnapshot = await firestore.collection('rooms').doc(roomNumber).get();
  const roomData = roomSnapshot.data();
  return roomData.players.length >= 4;
}

/**
 * DB 초기화 함수
 * @param roomNumber - 방 번호
 * @returns boolean
 */
async function resetRoom(roomNumber) {}

/**
 * 사용자가 호스트인지 확인하는 함수
 * @param userId - 사용자 id
 * @param roomNumber - 방 번호
 * @returns boolean
 */
async function isHost(userId, roomNumber) {}

module.exports = { createRoomData, generateRoomNumber, invalidRoomNumber, getUserData, isRoomFull, resetRoom, isHost };
