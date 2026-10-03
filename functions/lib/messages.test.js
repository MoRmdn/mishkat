"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const strict_1 = __importDefault(require("node:assert/strict"));
const node_test_1 = require("node:test");
const messages_1 = require("./messages");
const announcement = {
    titleAr: 'رمضان مبارك',
    titleEn: 'Ramadan Mubarak',
    bodyAr: 'أضفنا أذكار الإفطار.',
    bodyEn: 'We added the iftar athkar.',
};
(0, node_test_1.test)('an announcement goes to each language topic in that language', () => {
    const [ar, en] = (0, messages_1.announcementMessages)('a1', announcement);
    strict_1.default.equal(ar.topic, 'announcements_ar');
    strict_1.default.equal(ar.notification.title, 'رمضان مبارك');
    strict_1.default.equal(en.topic, 'announcements_en');
    strict_1.default.equal(en.notification.body, 'We added the iftar athkar.');
    // The app routes on data alone, and must match PushMessage.fromData.
    strict_1.default.deepEqual(ar.data, { type: 'announcement', id: 'a1' });
    strict_1.default.equal(ar.android.notification.channelId, 'mishkat_messages');
});
(0, node_test_1.test)('a reply is titled in the device language and routes to its thread', () => {
    const m = (0, messages_1.replyMessage)('tok', 'en', 't9', 'Thanks — fixed in 1.3.');
    strict_1.default.equal(m.token, 'tok');
    strict_1.default.equal(m.notification.title, 'You have a reply to your feedback');
    strict_1.default.equal(m.notification.body, 'Thanks — fixed in 1.3.');
    strict_1.default.deepEqual(m.data, { type: 'reply', threadId: 't9' });
    strict_1.default.equal((0, messages_1.replyMessage)('tok', 'ar', 't9', 'x').notification.title, 'وصل رد على ملاحظتك');
});
(0, node_test_1.test)('an unknown language falls back to Arabic', () => {
    strict_1.default.equal((0, messages_1.asLanguage)('fr'), 'ar');
    strict_1.default.equal((0, messages_1.asLanguage)(undefined), 'ar');
    strict_1.default.equal((0, messages_1.asLanguage)('en'), 'en');
});
(0, node_test_1.test)('a long reply is cut at a word, on one line', () => {
    strict_1.default.equal((0, messages_1.excerpt)('one\n\ntwo   three'), 'one two three');
    const long = 'word '.repeat(60);
    const cut = (0, messages_1.excerpt)(long, 50);
    strict_1.default.ok(cut.length <= 51);
    strict_1.default.ok(cut.endsWith('word…'));
});
(0, node_test_1.test)('only tokens FCM has given up on are pruned', () => {
    strict_1.default.ok((0, messages_1.isDeadToken)('messaging/registration-token-not-registered'));
    strict_1.default.ok((0, messages_1.isDeadToken)('messaging/invalid-registration-token'));
    strict_1.default.ok(!(0, messages_1.isDeadToken)('messaging/internal-error'));
    strict_1.default.ok(!(0, messages_1.isDeadToken)(undefined));
});
//# sourceMappingURL=messages.test.js.map