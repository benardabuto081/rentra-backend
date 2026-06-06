import {
  Controller,
  Post,
  Get,
  Patch,
  Body,
  Param,
  Query,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt.guard';
import { PaymentsService } from './payments.service';
import { PaymentType, PaymentMethod } from './payment.entity';

@UseGuards(JwtAuthGuard)
@Controller('organizations/:organizationId/payments')
export class PaymentsController {
  constructor(private paymentsService: PaymentsService) {}

  @Post()
  async create(
    @Param('organizationId') organizationId: string,
    @Body()
    body: {
      tenantId: string;
      roomId: string;
      buildingId: string;
      type: PaymentType;
      method: PaymentMethod;
      amount: number;
      amountPaid: number;
      month: number;
      year: number;
      mpesaCode?: string;
      notes?: string;
    },
  ) {
    return this.paymentsService.createPayment({ ...body, organizationId });
  }

  @Get()
  async findAll(@Param('organizationId') organizationId: string) {
    return this.paymentsService.findAll(organizationId);
  }

  @Get('arrears')
  async findArrears(@Param('organizationId') organizationId: string) {
    return this.paymentsService.findArrears(organizationId);
  }

  @Get('stats')
  async getStats(
    @Param('organizationId') organizationId: string,
    @Query('month') month: number,
    @Query('year') year: number,
  ) {
    return this.paymentsService.getMonthlyStats(organizationId, month, year);
  }

  @Get('month')
  async findByMonth(
    @Param('organizationId') organizationId: string,
    @Query('month') month: number,
    @Query('year') year: number,
  ) {
    return this.paymentsService.findByMonth(organizationId, month, year);
  }

  @Get('tenant/:tenantId')
  async findByTenant(
    @Param('organizationId') organizationId: string,
    @Param('tenantId') tenantId: string,
  ) {
    return this.paymentsService.findByTenant(tenantId, organizationId);
  }

  @Get(':id')
  async findOne(
    @Param('organizationId') organizationId: string,
    @Param('id') id: string,
  ) {
    return this.paymentsService.findById(id, organizationId);
  }

  @Patch(':id')
  async update(
    @Param('organizationId') organizationId: string,
    @Param('id') id: string,
    @Body()
    body: {
      amountPaid?: number;
      method?: PaymentMethod;
      mpesaCode?: string;
      notes?: string;
    },
  ) {
    return this.paymentsService.updatePayment(id, organizationId, body);
  }
}