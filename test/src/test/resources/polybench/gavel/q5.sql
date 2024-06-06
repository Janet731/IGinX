SELECT amount, timestamp, users, auction
FROM gavel.bid
WHERE gavel.bid.id>=0 AND gavel.bid.id<=1000000;