select gavel.bid.amount from gavel.user join gavel.bid on gavel.user.id = gavel.bid.user join gavel.auction on gavel.bid.user = gavel.auction.user;