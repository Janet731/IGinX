SELECT gavel.category.name, count(gavel.auction.id) as num
FROM gavel.auction INNER JOIN gavel.category ON gavel.auction.gavel.category = gavel.category.id
WHERE gavel.auction.end_date > 904694400000
GROUP BY gavel.category.name;