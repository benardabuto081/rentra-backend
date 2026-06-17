import { Test, TestingModule } from '@nestjs/testing';
import { ShadowRelationshipsController } from './shadow-relationships.controller';

describe('ShadowRelationshipsController', () => {
  let controller: ShadowRelationshipsController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [ShadowRelationshipsController],
    }).compile();

    controller = module.get<ShadowRelationshipsController>(ShadowRelationshipsController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
