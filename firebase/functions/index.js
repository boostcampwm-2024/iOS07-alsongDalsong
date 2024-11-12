const { onRequest } = require('firebase-functions/v2/https');
const admin = require('./FirebaseAdmin.js');
const { createRoom } = require('./api/CreateRoom.js');
const { startGame } = require('./api/StartGame.js');
const { uploadRecord } = require('./api/UploadRecord.js');
const { onRecordAdded } = require('./trigger/onRecordAdded.js');

// 방 생성 API
exports.createRoom = createRoom;

// GameStart API
exports.startGame = startGame;

// 녹음파일 업로드 API
exports.uploadRecording = uploadRecord;

// Record 추가 트리거
exports.onRecordAdded = onRecordAdded;
