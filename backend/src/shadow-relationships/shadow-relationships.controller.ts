import {
  Controller,
  Post,
  Get,
  Patch,
  Body,
  Param,
  Req,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt.guard';
import { ShadowRelationshipsService } from './shadow-relationships.service';
import {
  PaymentDestinationType,
  ShadowBillingCycle,
} from './shadow-relationship.entity';

@UseGuards(JwtAuthGuard)
@Controller('shadow-relationships')
export class ShadowRelationshipsController {
  constructor(
    private shadowRelationshipsService: ShadowRelationshipsService,
  ) {}

  // POST /shadow-relationships
  @Post()
  async create(
    @Req() req: any,
    @Body()
    body: {
      propertyNickname?: string;
      address?: string;
      rentAmount: number;
      billingCycle?: ShadowBillingCycle;
      dueDayOfMonth?: number;
      paymentDestinationType: PaymentDestinationType;
      paymentDestinationNumber: string;
      paymentReferenceName?: string;
    },
  ) {
    return this.shadowRelationshipsService.create({
      ...body,
      tenantUserId: req.user.userId,
    });
  }

  // GET /shadow-relationships
  @Get()
  async findMine(@Req() req: any) {
    return this.shadowRelationshipsService.findByTenant(req.user.userId);
  }

  // GET /shadow-relationships/:id
  @Get(':id')
  async findOne(@Req() req: any, @Param('id') id: string) {
    return this.shadowRelationshipsService.findById(id, req.user.userId);
  }

  // PATCH /shadow-relationships/:id
  @Patch(':id')
  async update(
    @Req() req: any,
    @Param('id') id: string,
    @Body() body: Partial<{
      propertyNickname: string;
      address: string;
      rentAmount: number;
      billingCycle: ShadowBillingCycle;
      dueDayOfMonth: number;
      paymentDestinationType: PaymentDestinationType;
      paymentDestinationNumber: string;
      paymentReferenceName: string;
    }>,
  ) {
    return this.shadowRelationshipsService.update(id, req.user.userId, body);
  }

  // PATCH /shadow-relationships/:id/end
  @Patch(':id/end')
  async end(@Req() req: any, @Param('id') id: string) {
    return this.shadowRelationshipsService.end(id, req.user.userId);
  }
}