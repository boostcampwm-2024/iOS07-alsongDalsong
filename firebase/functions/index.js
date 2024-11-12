const { onRequest } = require('firebase-functions/v2/https');
const admin = require('./FirebaseAdmin.js');
const { createRoom } = require('./api/CreateRoom.js');
const { joinRoom } = require('./api/JoinRoom.js');
const { startGame } = require('./api/StartGame.js');
const { uploadRecord } = require('./api/UploadRecord.js');
const { onRecordAdded } = require('./trigger/onRecordAdded.js');
const { onRoundEdited } = require('./trigger/onRoundEdited.js');

// 방 관련 API
exports.createRoom = createRoom;
exports.joinRoom = joinRoom;
exports.startGame = startGame;

// GameStart API
exports.startGame = startGame;

// 녹음파일 업로드 API
exports.uploadRecording = uploadRecord;

// Record 추가 트리거
exports.onRecordAdded = onRecordAdded;

// Round 추가 트리거
// exports.onRoundEdited = onRoundEdited;
