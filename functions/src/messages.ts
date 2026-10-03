// What each push looks like. Pure, so it is tested without Firebase
// (messages.test.ts). The app reads only `data`; the notification block is
// what the OS draws while the app is in the background or closed.

import type { Message } from 'firebase-admin/messaging';

/** Created by NotificationService on the device; also the manifest default. */
export const CHANNEL_ID = 'mishkat_messages';
export const LANGUAGES = ['ar', 'en'] as const;
export type Language = (typeof LANGUAGES)[number];

/** One topic per language: the app subscribes to its language's only. */
export const announcementTopic = (lang: Language) => `announcements_${lang}`;

export interface Announcement {
  titleAr: string;
  titleEn: string;
  bodyAr: string;
  bodyEn: string;
}

const android = { notification: { channelId: CHANNEL_ID, icon: 'ic_stat_mishkat' } };
const apns = { payload: { aps: { sound: 'default' } } };

/** An announcement to each language's topic, in that language. */
export function announcementMessages(id: string, a: Announcement): Message[] {
  return LANGUAGES.map((lang) => ({
    topic: announcementTopic(lang),
    notification: {
      title: lang === 'ar' ? a.titleAr : a.titleEn,
      body: lang === 'ar' ? a.bodyAr : a.bodyEn,
    },
    data: { type: 'announcement', id },
    android,
    apns,
  }));
}

const replyTitle: Record<Language, string> = {
  ar: 'وصل رد على ملاحظتك',
  en: 'You have a reply to your feedback',
};

export const asLanguage = (lang: unknown): Language =>
  lang === 'en' ? 'en' : 'ar';

/** The start of a reply, on one line, cut at a word where it can be. */
export function excerpt(body: string, max = 140): string {
  const flat = body.replace(/\s+/g, ' ').trim();
  if (flat.length <= max) return flat;
  const cut = flat.slice(0, max);
  const space = cut.lastIndexOf(' ');
  return `${(space > max * 0.6 ? cut.slice(0, space) : cut).trimEnd()}…`;
}

/** The owner's reply, to one of the sender's devices. */
export function replyMessage(
  token: string,
  lang: Language,
  threadId: string,
  body: string,
): Message {
  return {
    token,
    notification: { title: replyTitle[lang], body: excerpt(body) },
    data: { type: 'reply', threadId },
    android,
    apns,
  };
}

/** FCM's answer for a token that will never work again. */
export const isDeadToken = (code: string | undefined) =>
  code === 'messaging/registration-token-not-registered' ||
  code === 'messaging/invalid-registration-token';
