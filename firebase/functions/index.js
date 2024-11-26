const { onRequest } = require('firebase-functions/v2/https');
const admin = require('./FirebaseAdmin.js');
const { createRoom } = require('./api/CreateRoom.js');
const { joinRoom } = require('./api/JoinRoom.js');
const { startGame } = require('./api/StartGame.js');
const { uploadRecord } = require('./api/UploadRecord.js');
// const { onRecordAdded } = require('./trigger/onRecordAdded.js');
const { exitRoom } = require('./api/ExitRoom.js');
const { onRemovePlayer, onRemoveRoom } = require('./trigger/onRemovePlayer.js');
const { changeMode } = require('./api/ChangeMode.js');
const { submitMusic } = require('./api/SubmitMusic');

// 방 관련 API
exports.createRoom = createRoom;
exports.joinRoom = joinRoom;
exports.startGame = startGame;
exports.exitRoom = exitRoom;
exports.changeMode = changeMode;
exports.onRemoveRoom = onRemoveRoom;
exports.submitMusic = submitMusic;

// GameStart API
exports.startGame = startGame;

// 녹음파일 업로드 API
exports.uploadRecording = uploadRecord;

// Record 추가 트리거 (미완)
// exports.onRecordAdded = onRecordAdded;

// 방 나갈 경우 자동으로 삭제 트리거
exports.onRemovePlayer = onRemovePlayer;
