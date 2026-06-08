.data 
   #nomes que serao usados durante o codigo
   .eqv azul 0x539EF0
   .eqv preto 0x00000000
   .eqv branco 0x00FFFFFF 
   .eqv inicio_tela 0x10010000
   .eqv pixels 8192 
   .eqv ultima_linha 0x10017E00


#formula -> Endereco = base + (linha* 128 + coluna) * 4

.text
main:
	li $8, inicio_tela
	li $9, preto
	li $10, 0 #for "(i)"
	li $11, pixels
	
	
for:
	beq $10, $11, dados_horizontal1
	sw $9, 0($8)
	
	addi $8, $8, 4
	addi $10, $10, 1
	
	j for
	
dados_horizontal1:
	li $6, branco
	li $5, 0
	li $15, 108
	li $8, 0x10010028
	addi $8, $8, 4096        
		
for_horizontal1:
	beq $5, $15, dados_horizontal2
	sw $6, 0($8)               
	addi $8, $8, 4            
	addi $5, $5, 1
	
	j for_horizontal1
	
dados_horizontal2:
	li $6, branco
	li $5, 0
	li $15, 108   
	li $8, 0x10016A28   
	
for_horizontal2:
	beq $5, $15, dados_divisao_central
	
	sw $6, 0($8)
	addi $8, $8, 4
	addi $5, $5, 1
	
	j for_horizontal2
# Endereco = base + (linha* 128 + coluna) * 4	
dados_divisao_central:
	li $6, branco
	li $5, 0
	li $15, 22     
	li $8, 0x10010300
	addi $8, $8, 4096

for_centro:
	beq $5, $15, dados_divisao_central2
	sw $6, 0($8)
	
	addi $8, $8, 1024
	addi $5, $5, 1
	j for_centro
	
dados_divisao_central2:
	li $6, branco
	li $5, 0
	li $15, 22     
	li $8, 0x10010304
	addi $8, $8, 4096

for_centro2:
	beq $5, $15, dados_lateral1
	sw $6, 0($8)
	
	addi $8, $8, 1024
	addi $5, $5, 1
	j for_centro2
# Endereco = base + (linha* 128 + coluna) * 4
dados_lateral1:
	li $6, branco
	li $5, 0
	li $15, 44     
	li $8, 0x10011228
for_lateral1:
	beq $5, $15, dados_lateral2
	sw $6, 0($8)
	
	addi $8, $8, 512
	addi $5, $5, 1
	j for_lateral1
# Endereco = base + (linha* 128 + coluna) * 4
dados_lateral2:
	li $6, branco
	li $5, 0
	li $15, 44     
	li $8, 0x100113D4
for_lateral2:
	beq $5, $15, fim
	sw $6, 0($8)
	
	addi $8, $8, 512
	addi $5, $5, 1
	j for_lateral2	
			
fim:
	j fim
