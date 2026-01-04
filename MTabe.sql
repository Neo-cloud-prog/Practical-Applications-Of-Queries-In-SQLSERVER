declare @i int = 0;
declare @result int = 0;
 declare @IsColFull bit = 0;

WHILE @i <= 10
begin 
  declare @j int = 1; 
  declare @row varchar(50) = ' ';
  if @IsColFull = 1
  begin
   set @row = cast(@i as varchar);
  end;
  while @j <= 10
  begin
    if @IsColFull = 0
	begin
	  set @result = @j;
	end;
	else
	begin
	  set @result = @i * @j;
	end;

	if @result < 10
	  begin
	    set @row += '   ';
	  end
	  else
	  begin
	     if @i >= 10 and @result > 10
		 begin
		   set @row += ' ';
		 end;
		 else
		 begin
		   set @row += '  ';
		 end;
	  end;

	set @row = @row + Cast(@result as varchar);
    set @j = @j + 1;
  end;
  Print @row;
  set @IsColFull = 1;
  set @i = @i + 1;
end;