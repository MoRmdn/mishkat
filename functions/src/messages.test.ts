import assert from 'node:assert/strict';
import { test } from 'node:test';

import {
  announcementMessages,
  asLanguage,
  excerpt,
  isDeadToken,
  replyMessage,
} from './messages';

const announcement = {
  titleAr: 'رمضان مبارك',
  titleEn: 'Ramadan Mubarak',
  bodyAr: 'أضفنا أذكار الإفطار.',
  bodyEn: 'We added the iftar athkar.',
};

test('an announcement goes to each language topic in that language', () => {
  const [ar, en] = announcementMessages('a1', announcement) as any[];
  assert.equal(ar.topic, 'announcements_ar');
  assert.equal(ar.notification.title, 'رمضان مبارك');
  assert.equal(en.topic, 'announcements_en');
  assert.equal(en.notification.body, 'We added the iftar athkar.');
  // The app routes on data alone, and must match PushMessage.fromData.
  assert.deepEqual(ar.data, { type: 'announcement', id: 'a1' });
  assert.equal(ar.android.notification.channelId, 'mishkat_messages');
});

test('a reply is titled in the device language and routes to its thread', () => {
  const m = replyMessage('tok', 'en', 't9', 'Thanks — fixed in 1.3.') as any;
  assert.equal(m.token, 'tok');
  assert.equal(m.notification.title, 'You have a reply to your feedback');
  assert.equal(m.notification.body, 'Thanks — fixed in 1.3.');
  assert.deepEqual(m.data, { type: 'reply', threadId: 't9' });
  assert.equal(
    (replyMessage('tok', 'ar', 't9', 'x') as any).notification.title,
    'وصل رد على ملاحظتك',
  );
});

test('an unknown language falls back to Arabic', () => {
  assert.equal(asLanguage('fr'), 'ar');
  assert.equal(asLanguage(undefined), 'ar');
  assert.equal(asLanguage('en'), 'en');
});

test('a long reply is cut at a word, on one line', () => {
  assert.equal(excerpt('one\n\ntwo   three'), 'one two three');
  const long = 'word '.repeat(60);
  const cut = excerpt(long, 50);
  assert.ok(cut.length <= 51);
  assert.ok(cut.endsWith('word…'));
});

test('only tokens FCM has given up on are pruned', () => {
  assert.ok(isDeadToken('messaging/registration-token-not-registered'));
  assert.ok(isDeadToken('messaging/invalid-registration-token'));
  assert.ok(!isDeadToken('messaging/internal-error'));
  assert.ok(!isDeadToken(undefined));
});
