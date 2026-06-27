import { Injectable, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ConfigService } from '@nestjs/config';
import { Otp, OtpType, OtpStatus } from './otp.entity';
import { Resend } from 'resend';
import * as AfricasTalking from 'africastalking';

@Injectable()
export class OtpService {
  private resend: Resend;
  private sms: any;

  constructor(
    @InjectRepository(Otp)
    private otpRepository: Repository<Otp>,
    private configService: ConfigService,
  ) {
    this.resend = new Resend(this.configService.get<string>('RESEND_API_KEY'));

    const at = AfricasTalking({
      apiKey: this.configService.get<string>('AT_API_KEY'),
      username: this.configService.get<string>('AT_USERNAME'),
    });
    this.sms = at.SMS;
  }

  private generateCode(): string {
    return Math.floor(100000 + Math.random() * 900000).toString();
  }

  async sendOtp(recipient: string, type: OtpType): Promise<{ message: string }> {
    // Invalidate any existing pending OTPs for this recipient
    await this.otpRepository.update(
      { recipient, type, status: OtpStatus.PENDING },
      { status: OtpStatus.EXPIRED },
    );

    const code = this.generateCode();
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes

    const otp = this.otpRepository.create({
      recipient,
      type,
      code,
      status: OtpStatus.PENDING,
      expiresAt,
    });

    await this.otpRepository.save(otp);

    if (type === OtpType.PHONE) {
      await this.sendSmsOtp(recipient, code);
    } else {
      await this.sendEmailOtp(recipient, code);
    }

    return { message: `OTP sent to ${recipient}` };
  }

  async verifyOtp(
    recipient: string,
    type: OtpType,
    code: string,
  ): Promise<{ verified: boolean }> {
    const otp = await this.otpRepository.findOne({
      where: { recipient, type, status: OtpStatus.PENDING },
      order: { createdAt: 'DESC' },
    });

    if (!otp) {
      throw new BadRequestException('No pending OTP found. Please request a new one.');
    }

    if (otp.expiresAt < new Date()) {
      await this.otpRepository.update(otp.id, { status: OtpStatus.EXPIRED });
      throw new BadRequestException('OTP has expired. Please request a new one.');
    }

    if (otp.attempts >= 3) {
      throw new BadRequestException('Too many attempts. Please request a new OTP.');
    }

    if (otp.code !== code) {
      await this.otpRepository.update(otp.id, { attempts: otp.attempts + 1 });
      throw new BadRequestException('Invalid OTP code.');
    }

    await this.otpRepository.update(otp.id, { status: OtpStatus.VERIFIED });

    return { verified: true };
  }

  private async sendSmsOtp(phone: string, code: string): Promise<void> {
    try {
      await this.sms.send({
        to: [phone],
        message: `Your Rentra verification code is ${code}. It expires in 10 minutes. Do not share this code with anyone.`,
        from: 'RENTRA',
      });
    } catch (error) {
      throw new BadRequestException('Failed to send SMS. Please check your phone number.');
    }
  }

  private async sendEmailOtp(email: string, code: string): Promise<void> {
    try {
      await this.resend.emails.send({
        from: this.configService.get<string>('FROM_EMAIL') ?? 'onboarding@resend.dev',
        to: email,
        subject: 'Your Rentra Verification Code',
        html: `
          <div style="font-family: Arial, sans-serif; max-width: 480px; margin: 0 auto;">
            <h2 style="color: #1A56DB;">Verify your Rentra account</h2>
            <p>Your verification code is:</p>
            <div style="background: #F3F4F6; padding: 24px; text-align: center; border-radius: 8px; margin: 24px 0;">
              <span style="font-size: 36px; font-weight: bold; letter-spacing: 8px; color: #1A56DB;">${code}</span>
            </div>
            <p style="color: #6B7280;">This code expires in 10 minutes. Do not share it with anyone.</p>
            <p style="color: #6B7280;">If you did not request this, please ignore this email.</p>
          </div>
        `,
      });
    } catch (error) {
      throw new BadRequestException('Failed to send email. Please check your email address.');
    }
  }
}