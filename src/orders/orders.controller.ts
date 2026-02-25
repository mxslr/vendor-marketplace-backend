import { Controller, Post, Get, Patch, Param, Body, UseGuards, Request } from '@nestjs/common';
import { OrdersService } from './orders.service';
import { AuthGuard } from '../auth/auth.guard';

@Controller('orders')
export class OrdersController {
constructor(private ordersService: OrdersService) {}

@UseGuards(AuthGuard)
@Post()
create(@Request() req, @Body() body: { gigId: number }) {
    return this.ordersService.createOrder(req.user.sub, body.gigId);
}

@UseGuards(AuthGuard)
@Get('my-orders')
findMyOrders(@Request() req) {
    return this.ordersService.findMyOrders(req.user.sub);
}

@UseGuards(AuthGuard)
@Patch(':id/pay')
payOrder(@Request() req, @Param('id') id: string) {
    return this.ordersService.payOrder(Number(id), req.user.sub);
}

@UseGuards(AuthGuard)
@Get('incoming')
getIncomingOrders(@Request() req) {
    return this.ordersService.getIncomingOrders(req.user.sub);
}

@UseGuards(AuthGuard)
@Patch(':id/accept')
acceptOrder(@Request() req, @Param('id') id: string) {
    return this.ordersService.acceptOrder(Number(id), req.user.sub);
}

@UseGuards(AuthGuard)
@Patch(':id/complete')
completeOrder(@Request() req, @Param('id') id: string) {
    return this.ordersService.completeOrder(Number(id), req.user.sub);
}
}