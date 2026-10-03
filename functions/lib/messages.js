"use strict";
// What each push looks like. Pure, so it is tested without Firebase
// (messages.test.ts). The app reads only `data`; the notification block is
// what the OS draws while the app is in the background or closed.
Object.defineProperty(exports, "__esModule", { value: true });
exports.isDeadToken = exports.asLanguage = exports.announcementTopic = exports.LANGUAGES = exports.CHANNEL_ID = void 0;
exports.announcementMessages = announcementMessages;
exports.excerpt = excerpt;
exports.replyMessage = replyMessage;
/** Created by NotificationService on the device; also the manifest default. */
exports.CHANNEL_ID = 'mishkat_messages';
exports.LANGUAGES = ['ar', 'en'];
/** One topic per language: the app subscribes to its language's only. */
const announcementTopic = (lang) => `announcements_${lang}`;
exports.announcementTopic = announcementTopic;
const android = { notification: { channelId: exports.CHANNEL_ID, icon: 'ic_stat_mishkat' } };
const apns = { payload: { aps: { sound: 'default' } } };
/** An announcement to each language's topic, in that language. */
function announcementMessages(id, a) {
    return exports.LANGUAGES.map((lang) => ({
        topic: (0, exports.announcementTopic)(lang),
        notification: {
            title: lang === 'ar' ? a.titleAr : a.titleEn,
            body: lang === 'ar' ? a.bodyAr : a.bodyEn,
        },
        data: { type: 'announcement', id },
        android,
        apns,
    }));
}
const replyTitle = {
    ar: 'وصل رد على ملاحظتك',
    en: 'You have a reply to your feedback',
};
const asLanguage = (lang) => lang === 'en' ? 'en' : 'ar';
exports.asLanguage = asLanguage;
/** The start of a reply, on one line, cut at a word where it can be. */
function excerpt(body, max = 140) {
    const flat = body.replace(/\s+/g, ' ').trim();
    if (flat.length <= max)
        return flat;
    const cut = flat.slice(0, max);
    const space = cut.lastIndexOf(' ');
    return `${(space > max * 0.6 ? cut.slice(0, space) : cut).trimEnd()}…`;
}
/** The owner's reply, to one of the sender's devices. */
function replyMessage(token, lang, threadId, body) {
    return {
        token,
        notification: { title: replyTitle[lang], body: excerpt(body) },
        data: { type: 'reply', threadId },
        android,
        apns,
    };
}
/** FCM's answer for a token that will never work again. */
const isDeadToken = (code) => code === 'messaging/registration-token-not-registered' ||
    code === 'messaging/invalid-registration-token';
exports.isDeadToken = isDeadToken;
//# sourceMappingURL=messages.js.map