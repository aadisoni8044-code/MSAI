/**
 * Social Links & Content Payload Builder
 * Formats user input into clean, standardized QR code payloads for social networks,
 * web URLs, custom text, phone numbers, email, and Wi-Fi configurations.
 */

export class SocialLinksBuilder {
  /**
   * Generates QR payload string based on content type and input data
   * @param {string} type - Content type identifier (e.g., 'instagram', 'wifi', 'url')
   * @param {Object} data - Input form key-value pairs
   * @returns {string} Formatted QR code payload string
   */
  static buildPayload(type, data = {}) {
    switch (type) {
      case 'instagram': {
        const username = this.cleanUsername(data.username || 'instagram');
        return username.startsWith('http') ? username : `https://instagram.com/${username}`;
      }

      case 'youtube': {
        const channel = (data.channel || 'youtube').trim();
        if (channel.startsWith('http')) return channel;
        const handle = channel.startsWith('@') ? channel.substring(1) : channel;
        return `https://youtube.com/@${handle}`;
      }

      case 'facebook': {
        const username = (data.username || 'facebook').trim();
        if (username.startsWith('http')) return username;
        return `https://facebook.com/${this.cleanUsername(username)}`;
      }

      case 'whatsapp': {
        const rawPhone = (data.phone || '1234567890').replace(/[^0-9]/g, '');
        const text = data.message ? encodeURIComponent(data.message.trim()) : '';
        return text ? `https://wa.me/${rawPhone}?text=${text}` : `https://wa.me/${rawPhone}`;
      }

      case 'telegram': {
        const username = this.cleanUsername(data.username || 'telegram');
        if (username.startsWith('http')) return username;
        return `https://t.me/${username}`;
      }

      case 'twitter': {
        const username = this.cleanUsername(data.username || 'X');
        if (username.startsWith('http')) return username;
        return `https://x.com/${username}`;
      }

      case 'url': {
        let url = (data.url || 'https://example.com').trim();
        if (!url) return 'https://example.com';
        if (!/^https?:\/\//i.test(url)) {
          url = 'https://' + url;
        }
        return url;
      }

      case 'text': {
        return (data.text || 'Scan me with your camera').trim();
      }

      case 'phone': {
        const phone = (data.phone || '').trim();
        return phone ? `tel:${phone}` : 'tel:+1234567890';
      }

      case 'email': {
        const to = (data.email || 'hello@example.com').trim();
        const subject = data.subject ? encodeURIComponent(data.subject.trim()) : '';
        const body = data.body ? encodeURIComponent(data.body.trim()) : '';
        let mailto = `mailto:${to}`;
        const params = [];
        if (subject) params.push(`subject=${subject}`);
        if (body) params.push(`body=${body}`);
        if (params.length > 0) {
          mailto += `?${params.join('&')}`;
        }
        return mailto;
      }

      case 'wifi': {
        const ssid = this.escapeWifiString((data.ssid || 'My_WiFi').trim());
        const password = this.escapeWifiString((data.password || '').trim());
        const encryption = data.encryption || 'WPA';
        const hidden = data.hidden ? 'true' : 'false';
        return `WIFI:S:${ssid};T:${encryption};P:${password};H:${hidden};;`;
      }

      default:
        return 'https://example.com';
    }
  }

  /**
   * Sanitizes usernames by removing leading '@' symbols and trailing slashes
   */
  static cleanUsername(username) {
    if (!username) return '';
    let cleaned = username.trim();
    if (cleaned.startsWith('@')) {
      cleaned = cleaned.substring(1);
    }
    return cleaned;
  }

  /**
   * Escapes special characters in Wi-Fi SSID and Password according to MeCARD spec
   */
  static escapeWifiString(str) {
    if (!str) return '';
    return str.replace(/\\/g, '\\\\')
              .replace(/;/g, '\\;')
              .replace(/,/g, '\\,')
              .replace(/:/g, '\\:');
  }

  /**
   * Returns display label / preview summary for input payload
   */
  static getSummaryLabel(type, payload) {
    if (type === 'wifi') {
      const match = payload.match(/S:(.*?);/);
      return match ? `Wi-Fi Network: ${match[1]}` : 'Wi-Fi Network';
    }
    return payload;
  }
}
