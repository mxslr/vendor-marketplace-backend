import { Controller, Post, Get, Body, UseGuards, Request } from '@nestjs/common';
import { GigsService } from './gigs.service';
import { AuthGuard } from '../auth/auth.guard';

@Controller('gigs')
export class GigsController {
constructor(private gigsService: GigsService) {}

@UseGuards(AuthGuard)
@Post()
create(
    @Request() req, 
    @Body() body: { categoryId: number; title: string; description: string; price: number } 
) {
    return this.gigsService.createGig(
        req.user.sub,      
        body.categoryId,   
        body.title,        
        body.description,  
        body.price         
    );
    }

@Get()
findAll() {
    return this.gigsService.findAllGigs();
}
}