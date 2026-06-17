import { Test, TestingModule } from '@nestjs/testing';
import { ShadowRelationshipsService } from './shadow-relationships.service';

describe('ShadowRelationshipsService', () => {
  let service: ShadowRelationshipsService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [ShadowRelationshipsService],
    }).compile();

    service = module.get<ShadowRelationshipsService>(ShadowRelationshipsService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
