SELECT gavel.category.name, count(gavel.auction.id) as number
FROM gavel.auction INNER JOIN gavel.category ON gavel.auction.gavel.category = gavel.category.id
WHERE gavel.auction.end_date > $CURRENT_TIMESTAMP
GROUP BY gavel.category.name