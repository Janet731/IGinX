SELECT gavel.category.name, count(gavel.auction.id) as num
FROM gavel.auction INNER JOIN gavel.category ON gavel.auction.category = gavel.category.id
WHERE gavel.auction.end_date > 0
GROUP BY gavel.category.name;