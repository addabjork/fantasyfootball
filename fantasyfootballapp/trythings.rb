footballplayernew = Footballplayer.first(:name => name)
if footballplayernew.position == "QB"
	footballplayernew.getpassingyards
	puts "he has #{passingyards}"
else
	puts "he is not a quaterback"
end

if footballplayernew.position == "RB"
	footballplayernew.getrushyards
	puts "he has #{rushingyards}"
	footballplayernew.getreceivingyardsrb
	puts "he has #{receivingyardsrb}"
else
	puts "he is not a running back"
end

if footballplayernew.position == "WR"
	footballplayernew.getreceivingyardswr
	puts "he has #{receivingyardsrb}"
else
	puts "he is not a wide receiver"
end