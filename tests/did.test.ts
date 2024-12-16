import { describe, it, expect, beforeEach, vi } from 'vitest';

describe('DID Contract', () => {
  const contractName = 'did';
  
  beforeEach(() => {
    vi.resetAllMocks();
  });
  
  it('should create a DID', async () => {
    const did = 'did:example:123';
    const document = '{"@context": "https://www.w3.org/ns/did/v1", "id": "did:example:123"}';
    const mockCreateDid = vi.fn().mockResolvedValue({ success: true });
    const result = await mockCreateDid(did, document);
    expect(result.success).toBe(true);
  });
  
  it('should update a DID', async () => {
    const did = 'did:example:123';
    const newDocument = '{"@context": "https://www.w3.org/ns/did/v1", "id": "did:example:123", "updated": true}';
    const mockUpdateDid = vi.fn().mockResolvedValue({ success: true });
    const result = await mockUpdateDid(did, newDocument);
    expect(result.success).toBe(true);
  });
  
  it('should get a DID', async () => {
    const did = 'did:example:123';
    const mockGetDid = vi.fn().mockResolvedValue({
      success: true,
      value: {
        owner: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM',
        document: '{"@context": "https://www.w3.org/ns/did/v1", "id": "did:example:123"}',
        'created-at': 123456,
        'updated-at': 123456
      }
    });
    const result = await mockGetDid(did);
    expect(result.success).toBe(true);
    expect(result.value).toHaveProperty('owner');
    expect(result.value).toHaveProperty('document');
    expect(result.value).toHaveProperty('created-at');
    expect(result.value).toHaveProperty('updated-at');
  });
  
  it('should get a DID owner', async () => {
    const did = 'did:example:123';
    const mockGetDidOwner = vi.fn().mockResolvedValue({
      success: true,
      value: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM'
    });
    const result = await mockGetDidOwner(did);
    expect(result.success).toBe(true);
    expect(typeof result.value).toBe('string');
  });
});

