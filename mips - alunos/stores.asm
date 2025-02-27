#lui $10, 4097		#linha necessaria pra testar no mars
lui $2, 32767	
addi $2, $2, 32639

sw $2, 100($10)	
sb $2, 116($10)
lw $3, 100($10)		
lw $5, 116($10)	
