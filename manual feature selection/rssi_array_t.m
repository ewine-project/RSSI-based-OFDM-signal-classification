function result = rssi_array_t(array,N,islinear)

 arrayint = array(mod(length(array),N)+1:end);
 arraylength=length(arrayint);
 num_of_block = floor(arraylength/N);

 result = [];
 for i= 1:num_of_block;
     offset = N*(i-1);
     datablock = array(offset+1:offset+N);
     if (islinear == 0)
        rssi = 10*log10( sum( abs(datablock).^2 )/N );
     else
        rssi = sum( abs(datablock).^2 )/N ; 
     end
     result= [ result rssi];
 end    