import { Controller, Post, Get, Patch, Param, Body, UseGuards, Request, UnauthorizedException } from '@nestjs/common';
import { MerchantsService } from './merchants.service';
import { AuthGuard } from '../auth/auth.guard';

@Controller('merchants')
export class MerchantsController {
    constructor(private merchantsService: MerchantsService) {}

    @UseGuards(AuthGuard)
    @Post()
    create(@Request() req, @Body() body: { shopName: string; description?: string }) {
        return this.merchantsService.createMerchant(req.user.sub, body.shopName, body.description);
    }

    @Get()
    findAll() {
        return this.merchantsService.findAllMerchants();
    }

    @UseGuards(AuthGuard)
    @Patch('submit-kyb')
    submitKyb(
        @Request() req, 
        @Body() body: { kybDocumentsUrl: string }
    ) {
        return this.merchantsService.submitKyb(req.user.sub, body.kybDocumentsUrl);
    }

    // (Catatan: Endpoint ini mungkin bisa dihapus nantinya karena tugas approval 
    // sudah dipindahkan ke modul khusus Admin Validator yang lebih lengkap)
    @UseGuards(AuthGuard)
    @Patch(':id/approve')
    approve(@Request() req, @Param('id') id: string) {
        const userRole = req.user.role;
        
        if (userRole !== 'SUPER_ADMIN' && userRole !== 'ADMIN_VALIDATOR') {
            throw new UnauthorizedException('Akses ditolak. Hanya Admin yang dapat menyetujui toko.');
        }

        return this.merchantsService.approveMerchant(Number(id));
    }
}