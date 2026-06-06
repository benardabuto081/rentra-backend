import {
  Controller,
  Post,
  Get,
  Patch,
  Body,
  Param,
  Query,
} from '@nestjs/common';
import { PaymentsService } from './payments.service';
import { PaymentType, PaymentMethod } from './payment.entity';

@Controller('organizations/:organizationId/payments')
export class PaymentsController {
  constructor(private paymentsService: PaymentsService) {}

  // POST /organizations/:organizationId/payments
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

  // GET /organizations/:organizationId/payments
  @Get()
  async findAll(@Param('organizationId') organizationId: string) {
    return this.paymentsService.findAll(organizationId);
  }

  // GET /organizations/:organizationId/payments/arrears
  @Get('arrears')
  async findArrears(@Param('organizationId') organizationId: string) {
    return this.paymentsService.findArrears(organizationId);
  }

  // GET /organizations/:organizationId/payments/stats?month=6&year=2026
  @Get('stats')
  async getStats(
    @Param('organizationId') organizationId: string,
    @Query('month') month: number,
    @Query('year') year: number,
  ) {
    return this.paymentsService.getMonthlyStats(organizationId, month, year);
  }

  // GET /organizations/:organizationId/payments/month?month=6&year=2026
  @Get('month')
  async findByMonth(
    @Param('organizationId') organizationId: string,
    @Query('month') month: number,
    @Query('year') year: number,
  ) {
    return this.paymentsService.findByMonth(organizationId, month, year);
  }

  // GET /organizations/:organizationId/payments/tenant/:tenantId
  @Get('tenant/:tenantId')
  async findByTenant(
    @Param('organizationId') organizationId: string,
    @Param('tenantId') tenantId: string,
  ) {
    return this.paymentsService.findByTenant(tenantId, organizationId);
  }

  // GET /organizations/:organizationId/payments/:id
  @Get(':id')
  async findOne(
    @Param('organizationId') organizationId: string,
    @Param('id') id: string,
  ) {
    return this.paymentsService.findById(id, organizationId);
  }

  // PATCH /organizations/:organizationId/payments/:id
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