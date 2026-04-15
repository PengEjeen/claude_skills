// Test suite for ContextCompressor
import { ContextCompressor } from '../src/context-compressor';
import { describe, it, expect } from '@jest/globals';

describe('ContextCompressor', () => {
  let compressor: ContextCompressor;

  beforeEach(() => {
    compressor = new ContextCompressor();
  });

  describe('Basic Compression', () => {
    it('should compress long file paths', () => {
      const input = 'Check src/components/user/profile/settings/AccountSettings.tsx';
      const result = compressor.compress(input, { level: 'light' });

      expect(result.compressed).toContain('.../settings/AccountSettings.tsx');
      expect(result.compressionRatio).toBeGreaterThan(1);
    });

    it('should compress repeated long names', () => {
      const input = `
        const UserAuthenticationService = new UserAuthenticationService();
        UserAuthenticationService.login();
        UserAuthenticationService.logout();
      `;
      const result = compressor.compress(input, { level: 'light' });

      expect(result.compressed).toContain('UAS');
      expect(result.techniques).toContain('Reference Substitution');
    });
  });

  describe('Code Skeleton Extraction', () => {
    it('should extract function signatures', () => {
      const input = `
        function calculateDiscount(order: Order): number {
          const items = order.items;
          let total = 0;
          for (const item of items) {
            total += item.price * item.quantity;
          }
          const discount = total * 0.1;
          return discount;
        }
      `;

      const result = compressor.compress(input, { level: 'medium' });

      expect(result.compressed).toContain('function calculateDiscount');
      expect(result.compressed).toContain('return');
      expect(result.compressedTokens).toBeLessThan(result.originalTokens);
    });

    it('should preserve important lines', () => {
      const input = `
        async function fetchUser(id: string) {
          console.log('Fetching user...');
          const response = await fetch(\`/api/users/\${id}\`);
          if (!response.ok) throw new Error('Failed');
          console.log('Success');
          return response.json();
        }
      `;

      const result = compressor.compress(input, { level: 'medium' });

      expect(result.compressed).toContain('await fetch');
      expect(result.compressed).toContain('throw');
      expect(result.compressed).toContain('return');
    });
  });

  describe('Auto-trigger', () => {
    it('should not compress when context usage < 60%', () => {
      const input = 'Short content';
      const result = compressor.autoCompress(input, 0.5);

      expect(result).toBeNull();
    });

    it('should apply light compression at 60-80%', () => {
      const input = 'Some content to compress';
      const result = compressor.autoCompress(input, 0.7);

      expect(result).not.toBeNull();
      expect(result!.techniques).toContain('Reference Substitution');
    });

    it('should apply heavy compression at 90%+', () => {
      const input = 'Content needing heavy compression';
      const result = compressor.autoCompress(input, 0.95);

      expect(result).not.toBeNull();
      expect(result!.techniques.length).toBeGreaterThanOrEqual(2);
    });
  });

  describe('Quality Metrics', () => {
    it('should measure token savings', () => {
      const original = 'const UserAuthenticationService = new UserAuthenticationService();';
      const compressed = 'const UAS = new UAS();';

      const quality = compressor.measureQuality(original, compressed);

      expect(quality.tokenSavings).toBeGreaterThan(30);
      expect(quality.score).toBeGreaterThan(50);
    });

    it('should measure information retention', () => {
      const original = 'function calculateTotal(items) { return items.reduce((sum, item) => sum + item.price, 0); }';
      const compressed = 'function calculateTotal(items) { return items.reduce(...); }';

      const quality = compressor.measureQuality(original, compressed);

      expect(quality.informationRetention).toBeGreaterThan(70);
    });
  });

  describe('Multilingual Support', () => {
    it('should compress Korean text', () => {
      const input = `
        // 사용자 인증 서비스
        const 사용자인증서비스 = new 사용자인증서비스();
        사용자인증서비스.로그인();
        사용자인증서비스.로그아웃();
      `;

      const result = compressor.compress(input, { level: 'light' });

      expect(result.compressionRatio).toBeGreaterThan(1);
    });

    it('should preserve Korean keywords', () => {
      const input = '에러: 데이터베이스 연결 실패';
      const result = compressor.compress(input, { level: 'medium' });

      expect(result.compressed).toContain('에러');
      expect(result.compressed).toContain('데이터베이스');
    });
  });

  describe('Edge Cases', () => {
    it('should handle empty input', () => {
      const result = compressor.compress('', { level: 'medium' });

      expect(result.originalTokens).toBe(0);
      expect(result.compressedTokens).toBe(0);
    });

    it('should handle very short input', () => {
      const result = compressor.compress('hi', { level: 'heavy' });

      expect(result.compressed).toBe('hi');
    });

    it('should not break valid code', () => {
      const input = `
        function add(a: number, b: number): number {
          return a + b;
        }
      `;

      const result = compressor.compress(input, { level: 'heavy' });

      // Should still be parseable (simplified check)
      expect(result.compressed).toContain('function');
      expect(result.compressed).toContain('return');
    });
  });
});
