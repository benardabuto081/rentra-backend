import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Payment, PaymentType, PaymentStatus, PaymentMethod } from './payment.entity';

@Injectable()
export class PaymentsService {
  constructor(
    @InjectRepository(Payment)
    private paymentsRepository: Repository<Payment>,
  ) {}

  async createPayment(data: {
    organizationId: string;
    tenantId: string;
    roomId: string;
    buildingId: string;
    type: PaymentType;
    method: PaymentMethod;
    amount: number;
    amountPaid: number;
    month: number;
    year: number;
    dueDate?: Date;
    mpesaCode?: string;
    notes?: string;
  }): Promise<Payment> {
    const status = this.calculateStatus(data.amount, data.amountPaid);
    const receiptNumber = this.generateReceiptNumber();
    const paidAt = data.amountPaid > 0 ? new Date() : null;

    let daysLate = 0;
    if (data.dueDate && paidAt) {
      const diff = paidAt.getTime() - new Date(data.dueDate).getTime();
      daysLate = Math.max(0, Math.floor(diff / (1000 * 60 * 60 * 24)));
    }

    const payment = this.paymentsRepository.create({
      ...data,
      status,
      receiptNumber,
      paidAt,
      daysLate,
    });

    return this.paymentsRepository.save(payment);
  }

  async findAll(organizationId: string): Promise<Payment[]> {
    return this.paymentsRepository.find({
      where: { organizationId },
      order: { createdAt: 'DESC' },
    });
  }

  async findByTenant(tenantId: string, organizationId: string): Promise<Payment[]> {
    return this.paymentsRepository.find({
      where: { tenantId, organizationId },
      order: { year: 'DESC', month: 'DESC' },
    });
  }

  async findByRoom(roomId: string, organizationId: string): Promise<Payment[]> {
    return this.paymentsRepository.find({
      where: { roomId, organizationId },
      order: { year: 'DESC', month: 'DESC' },
    });
  }

  async findByMonth(
    organizationId: string,
    month: number,
    year: number,
  ): Promise<Payment[]> {
    return this.paymentsRepository.find({
      where: { organizationId, month, year },
      order: { createdAt: 'DESC' },
    });
  }

  async findById(id: string, organizationId: string): Promise<Payment> {
    const payment = await this.paymentsRepository.findOne({
      where: { id, organizationId },
    });
    if (!payment) {
      throw new NotFoundException('Payment not found');
    }
    return payment;
  }

  async findArrears(organizationId: string): Promise<Payment[]> {
    return this.paymentsRepository.find({
      where: [
        { organizationId, status: PaymentStatus.PENDING },
        { organizationId, status: PaymentStatus.PARTIAL },
      ],
      order: { year: 'ASC', month: 'ASC' },
    });
  }

  async updatePayment(
    id: string,
    organizationId: string,
    data: {
      amountPaid?: number;
      method?: PaymentMethod;
      mpesaCode?: string;
      notes?: string;
    },
  ): Promise<Payment> {
    const payment = await this.findById(id, organizationId);
    const newAmountPaid = data.amountPaid ?? Number(payment.amountPaid);
    const status = this.calculateStatus(Number(payment.amount), newAmountPaid);

    await this.paymentsRepository.update(id, {
      ...data,
      status,
      paidAt: newAmountPaid > 0 ? new Date() : payment.paidAt,
    });

    return this.findById(id, organizationId);
  }

  async getMonthlyStats(
    organizationId: string,
    month: number,
    year: number,
  ): Promise<{
    totalExpected: number;
    totalCollected: number;
    totalArrears: number;
    paymentCount: number;
  }> {
    const payments = await this.findByMonth(organizationId, month, year);
    const totalExpected = payments.reduce((sum, p) => sum + Number(p.amount), 0);
    const totalCollected = payments.reduce((sum, p) => sum + Number(p.amountPaid), 0);
    const totalArrears = totalExpected - totalCollected;

    return {
      totalExpected,
      totalCollected,
      totalArrears,
      paymentCount: payments.length,
    };
  }

  private calculateStatus(amount: number, amountPaid: number): PaymentStatus {
    if (amountPaid <= 0) return PaymentStatus.PENDING;
    if (amountPaid >= amount) return PaymentStatus.COMPLETED;
    return PaymentStatus.PARTIAL;
  }

  private generateReceiptNumber(): string {
    const timestamp = Date.now().toString().slice(-6);
    const random = Math.floor(Math.random() * 1000).toString().padStart(3, '0');
    return `RNT-${timestamp}-${random}`;
  }
}