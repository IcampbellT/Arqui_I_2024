;proyecto 1 arquitectura de Computadores
%include "linux64.inc"

section .data
;varibles inicializadas

archconf db "config_numeric.txt",0	;Configuracion
archdat db "estudiantes.txt",0  ;Datos
voyaqui db 0x1b,"[44;31m","voy por aqui",10

exis db "x "
dobleespacio db "  "
espacioyenter db " ",10
finalfila db "|"
cuatroespacios db "    "
cien db "100 "
verde db 0x1b,"[32m"
rojo db 0x1b,"[31m"
blanco db 0x1b,"[37m"
amarillo db 0x1b,"[33m"



section .bss
;Valores iniciales rservados

textconf resb 1500 ; config
textdat resb 2048 ; datos
ttc resb 1500  ; config
ttd resb 2048 ; datos

byteactual resw 1	; contador posicion se esta leyendo
finalf1 resw 1		;posicion relativa donde se encuentra el final de la fila 1
iniciof1 resw 1		;posicion relativa donde inicia la fila 1
iniciof2 resw 1		;posicion relativa donde inicia la fila 2
finalf2 resw 1		;osicion relaiva donde finaliza la fila 2


bytefinaltext resw 1	;posicion relativa final documento datos
contadorletras resw 1
copiadorfilas resw 1

sizef1 resw 1		;tamaño de la fila 1
sizef2 resw 1		;tamaño de la fila 2

bubletimes resw 1
contadorfilas resw 1


arraynotas resb 2048		;notas en el eje x
arrayestudiantes resb 2048	;cantidad de estudiantes por grupo de notas


nota resb 1
num1 resb 2
num2 resb 2

todaslasnotas resb 2048


;Las siguientes variables pertenecen a informacion del archivo configuracion
	nda resb 3 ;almacena la nda= nota de aprobacion
	ndr resb 2 ;almacena la ndr = nota de  reposicion
	tdgn resb 2 ;tdgn =tamaño de los grupos de notas
	edg resb 2 ;edg = escala del grafico
	tdo resb 1;tdo = tipo de ordenamiento

;las siguientes variables se utilizan para realizar las comparaciones

	letra1 resb 1
	letra2 resb 1
	copiafila1 resb 40	;almacena la fila 1
	copiafila2 resb 40	;almacena la fila 2



;variables histograma
	canty resw 1
	cantx resw 1
	edgb resb 1
	residuoy resb 1
	residuox resb 1
	tdgnb resb 1

	arrayaxisy resb 2048	;guarda los valores presentes en el eje y




section .text
	global _start
	_start:		


	;leer el archivo de config
	; Abriendo el archivo
		mov rax, SYS_OPEN
		mov rdi, archconf
		mov rsi, O_RDONLY
		mov rdx, 0
		syscall

	
		push rax
		mov rdi, rax
		mov rax, SYS_READ
		mov rsi, textconf
		mov rdx,ttc
		syscall

	;cerrando el archivo
		mov rax, SYS_CLOSE
		pop rdi
		syscall


	;imprimir Texto leido
		print textconf

	;extraer informacion del texto leido
		;leyendo nota de aprobación
		mov ax,[textconf+21] ; almacena en ax el contenido de la direccion
		mov word [nda], ax	; almacena en nda el contenido de ax
		;leyendo nota de  reposición
                mov ax,[textconf+45]
                mov word [ndr],ax
		;leyendo Escala del gráfico
                mov ax,[textconf+105] ; almacena en ax el contenido de la direc$
                mov word [edg], ax   ; almacena en edg el contenido de ax
		;leyendo Tipo de Ordenamiento
                mov al,[textconf+122] ; almacena en ax el contenido de la direc$
                mov byte [tdo], al   ; almacena en tdo el contenido de ax


        

        ; Abriendo el archivo
                mov rax, SYS_OPEN
                mov rdi, archdat
                mov rsi, O_RDONLY
                mov rdx, 0
                syscall

        ;Leyendo el  archivo
                push rax
                mov rdi, rax
                mov rax, SYS_READ
                mov rsi, textdat
                mov rdx,ttd
                syscall

        ;cerrando el archivo
                mov rax, SYS_CLOSE
                pop rdi
                syscall

	; imprimir texto con datos
		print textdat






mov word [bubletimes],0d	;se limpia la variable que se va a utilizar como contador

limpiarvariables:
;limpiar variables a utilizar
mov word [byteactual],0d
mov word [iniciof1],0d
mov word [finalf1],0d
mov word [iniciof2],0d
mov word [finalf2],0d

mov word [bytefinaltext],900d
mov word [contadorletras],0d
mov word [copiadorfilas],0d
mov word [sizef1],0d
mov word [sizef2],0d
mov word [contadorfilas],1d




bublesort:


	;Determinar el inicio y el final de la fila 1
	;cargar letra actual
        mov word bx,[byteactual]
	mov byte al, [textdat +rbx ]

	;Copiar letra actual en direccion copiafila1+copiadorfilas
		mov word r10w,[copiadorfilas]
		mov byte [copiafila1+r10],al

	;incrementar copiador filas
		add word r10w,1d
		mov word [copiadorfilas],r10w

        ; Almacena  byteactual en final fila 1
                mov word cx,[byteactual]
		mov word  [finalf1], cx

	; incrementa el byte actual
		mov word [byteactual],cx
		add word cx, 1d
		mov word [byteactual],cx


	;Es letra actual igual a enter?
		cmp byte al,10d ; compara letra actual
		jne bublesort

	;Guardar copiador filas en tamañofila 1
		mov word r9w,[copiadorfilas]
		mov word [sizef1],r9w

	;limpiar copiador filas
		mov word [copiadorfilas],0d

	;Almacenar byte actual en inicio de fila 2

		mov word [iniciof2],cx

	;incrementa contador filas
		mov word r11w,[contadorfilas]
		add word r11w, 1d
		mov word [contadorfilas],r11w



	; cargar letra actual
Efila2:		mov word ax,[byteactual]
		mov byte bl,[textdat+rax]

	;Copiar letra actual en  direccion copiafila2+copiadorfilas
		mov word r8w,[copiadorfilas]
		mov byte [copiafila2+r8],bl

	;incrementar copiador de filas
		add word r8w,1d
		mov word [copiadorfilas],r8w

	;Almacenar en final fila 2 el byte actual
		mov word [finalf2],ax
	;Incrementar byte actual
		add word ax,1d
		mov word [byteactual],ax



;es la letra siguiente igual al final del archivo?

        mov byte r13b,[textdat+rax]
        cmp byte r13b,0d
        jne igualenter
;si la siguiente letra es igual al final entonces almacena el byteactual
        mov word  [bytefinaltext],ax
	mov word [bytefinaltext],ax


        ; Es letra actual igual a enter?
igualenter:
		 cmp byte bl,10d
                jne Efila2







antesdeordenamiento:
	;Guardar copiadorfila en tamaño de fila 2
		mov word r8w,[copiadorfilas]
		mov word [sizef2],r8w

	;limpiar copiador filas
		mov word [copiadorfilas],0d

	;ordenamiento
ordenamiento:
	;Es tipo de ordenamiento alfabetico
	;comprueba si la letra inicial es una A mayuscula
	mov byte al,[tdo]
	cmp byte al,65d
	je alfabetico
	;comprueba si la letra inicial es una a minuscuala
        mov byte al,[tdo]
        cmp byte al,97d
        je alfabetico


;ordenamiento por  notas


;buscar nota en fila 1
;cargar bytes finales en registros
	mov word ax,[finalf1]
	mov word bx,[finalf2]
	;retroceder una posicion para cargar  las unidades
	sub word ax,1d
	sub word bx,1d
	;cargar unidades
	mov byte cl,[textdat+rax]
	mov byte dl,[textdat+rbx]
	mov byte [num1+1],cl
	mov byte [num2+1],dl


	;retroceder una posicion mas para cargar las decenas
	sub word ax,1d
        sub word bx,1d
        ;cargar unidades
        mov byte cl,[textdat+rax]
        mov byte dl,[textdat+rbx]
        mov byte [num1],cl
        mov byte [num2],dl


;comparacion entre numeros
;cargar las decenas
	mov byte al,[num1]
	mov byte bl,[num2]
	cmp byte al,bl
	jg letra1menor
	jb letra1mayor

;si el primer digito es igual entonces hay que cargar el segundo digito y comparar
;cargar las unidades
        mov byte al,[num1+1]
        mov byte bl,[num2+1]
        cmp byte al,bl
        jg letra1menor
        jb letra1mayor
;si ambos numeros son iguales se deja que se ordenen alfabeticamente



;ordenamiento alfabetico
alfabetico:

	;cargar en letra1 lo que esta en la direccion textdat+iniciof1+ contadorletras
		mov word ax,[iniciof1]
		add word ax,[contadorletras]
		mov byte cl,[textdat+rax]
		mov byte [letra1],cl
	;Cargar en letra 2 lo que esta en el textdat+iniciof2+contadorletras
                mov word ax,[iniciof2]
                add word ax,[contadorletras]
                mov byte cl,[textdat+rax]
                mov byte [letra2],cl


	;incrementar contador letras
		mov word dx,[contadorletras]
		add word dx,1d
		mov word [contadorletras],dx

	;Es letra1 igual a letra2
		mov byte al,[letra1]
		mov byte bl,[letra2]
		cmp byte al,bl
		je alfabetico


	;limpiar contador letras
		mov byte [contadorletras],0d

	;limpiar copiador letras
		mov byte [copiadorfilas],0d


	;es letra1 mayor a letra2?
		jg  letra1mayor




	;letra1 es menor a letra 2
letra1menor:
	;actualiza el inicio para el siguiente loop
	; iniciof1=iniciof2
	mov word r12w,[iniciof2]
	mov word [iniciof1],r12w

	;posicionar el la posicion actual en el inicio de la nueva fila 2
	;byteactual=iniciof2
	mov word [byteactual],r12w

	;Salto  a final del remplazo
	jmp finaldelremplazo

	;letra 1 es mayor que letra 2
letra1mayor:
	;copiar fila 2 en textdat
	;cargar en al lo que esta en copiafila2+copiadorfilas
		mov word bx,[copiadorfilas]
		mov byte al,[copiafila2+rbx]

	;Copiar al en direccion textdat+iniciof1+copiadorfilas
		add word bx,[iniciof1]
		mov byte [textdat+rbx],al

	;incrementar copiador filas
		mov word dx,[copiadorfilas]
		add word dx,1d
		mov word [copiadorfilas],dx

	; Es copiador filas mayor a tamaño fila 2?
		mov word ax,[sizef2]
		cmp word dx,ax
		jb letra1mayor

	;actualizar byte actual byteactual=iniciof1+sizef2+1 o = iniciof1+copiadorfilas +1
		mov word ax,[copiadorfilas]
		add ax,[iniciof1]
		mov word [byteactual],ax

	  ;limpiar copiador filas
                mov word [copiadorfilas],0d


copyf1: ;copiar fila 1
	;Cargar en al lo que esta en copiafila1+copiadorfilas
		mov word bx,[copiadorfilas]
		mov byte al,[copiafila1+rbx]

	;copiar al en direccion textdat+byteactual+copiadorfilas
		add word bx,[byteactual]
		;dec word bx
		mov byte [textdat+rbx],al

	;incrementar copiador filas
		mov word bx,[copiadorfilas]
		add word bx,1d
		mov word [copiadorfilas],bx

	; Es copiadorfilas mayor a tamañofila1?
		mov word ax,[sizef1]
		cmp word bx,ax
		jb copyf1


	;Limpiar copiador de filas
		mov word [copiadorfilas],0d

	;iniciof1=byteactual
		mov word ax,[byteactual]
		mov word [iniciof1],ax


finaldelremplazo:

;es finalf2 el final del documento?

	mov word ax,[finalf2]
	mov word bx, [bytefinaltext]
	cmp word ax,bx

	jb bublesort




;incrementando bubletimes
	mov word ax,[bubletimes]
	add word ax,1d
	mov word [bubletimes],ax

; es el la cantidad de veces igual a la cantidad de filas

	mov word bx,[contadorfilas]
	mov word [contadorfilas],0d
	cmp word ax,bx
	jb limpiarvariables






;---------------------Histograma----------------------
;Determinar numero de filas del histograma
;cantidad de valores en eje y=division entera(100/escala del grafico)
;si residuo es mayor a 1, se le suma residuo al ultimo grupo

;convirtiendo edg a decical
	mov byte ah,[edg]
	mov byte al,[edg+1]
	mov byte [num1],ah
	mov byte [num2],al
	call _wascii2dec
	mov byte [edgb],al


;limpiar contador canty
	mov word [canty],1d
	mov byte [arrayaxisy],0d
;el registro cl es un acomulador, limpiarlo antes de usar
	xor rcx,rcx
calculoejey:
	;arrayaxisy
	;carga el contador
	mov word ax,[canty]
	;carga dato a acumular
	add byte cl,[edgb]
	;cargar el dato el arreglo
	mov byte [arrayaxisy+rax],cl
	;incrementa contador
	add word ax,1d
	;guarda el contador en canty
	mov word [canty],ax
	;se compara que el dato sea menor que 100
	cmp byte cl,100d
	jb calculoejey











;------------tamaño de los grupos de notas------------
 ;leyendo el tamaño de los grupos de notas
                mov byte ah,[textconf+80]
		mov byte al,[textconf+81]
                mov byte [tdgn], ah
		mov byte [tdgn+1],al
		mov byte [num1],ah
		mov byte [num2],al
		call _wascii2dec
		mov byte [tdgnb],al


;limpiar variables para la division
		xor rax,rax
		xor rbx,rbx
;dividir 100 entre el tamaño de los grupos
        mov byte al, 100d
        mov byte bl,[tdgnb]
        div byte bl
        mov byte [cantx],al

;Calcular residuox
       mov byte [residuox],ah

; si hay residuo se agrega un nuevo grupo de notas
	mov byte bl,[residuox]
	cmp bl,0d
	je residuo2
	mov byte al,[cantx]
	add byte al,1d
	mov byte [cantx],al

residuo2:
	mov byte bl, [residuoy]
	cmp bl,0d
	je finalresiduo
	mov byte al,[canty]
	add byte al,1d
	mov byte [canty],al

finalresiduo:



;----------------Clasificar notas------------------


;limpiar vector notas y estudiantes
	mov byte dl,0d
limpiarnotas:	; aqui se limpia el arreglo que va a contener las notas y el que va a contener los estudiantes por nota
		mov byte [arraynotas+rdx],0d
		mov byte [arrayestudiantes+rdx],0d
		cmp byte dl,100d
		add byte dl,1d
		jb limpiarnotas

; asignar notas a arreglo de notas
		mov byte dl,1d ; el registro dl es un contador
		mov byte r9b,[cantx]
		mov byte bl,[tdgnb]
		mov byte [nota],0d
asignarnotas:
		;calcular nota
		;multiplicar tamaño por el contador
		;asi se obtiene limite actual del grupo
		mov byte al,dl
		mul byte bl
		mov byte [nota],al
		mov byte al,dl
		sub byte al,1d
		mov byte r14b,[nota]
		mov byte [arraynotas+rax],r14b
		;incrementar contador
		add byte dl,1d
		mov byte r10b,dl
		;comparar si ya se llego al final de los grupos
		cmp byte r10b,r9b
		jbe asignarnotas




;limpiar variable contador
	mov word [contadorfilas],0d
	mov word [byteactual],0d

findnotes:	;buscar notas en el archivo textdat
		;detectar el enter
		;la cantidad de enters detectados debe ser menor o igual bubletimes
		;detectando enter
		mov word bx,[byteactual]
		mov byte al,[textdat+rbx]	;carga en al la letra actual
		;incrementar el byte actual
		add word bx,1d
		mov word [byteactual],bx
		;comprobar si la  letra es igual a enter
		cmp byte al, 10d
		jne findnotes

		;encontro el enter
enter:		;incrementar contador filas
		mov word cx,[contadorfilas]
		add word cx,1d
		mov word [contadorfilas],cx
		;carga el numero
		;cargar unidades
		mov word bx,[byteactual]
		sub word bx,2d
		mov byte al,[textdat+rbx]
		mov byte [num1+1],al
		;carga decenas
		sub word bx,1d
		mov byte al,[textdat+rbx]
		cmp byte al,32	;es igual a un espacio?
		jne nospace
		mov byte al,48d

nospace:	mov byte [num1],al
		;convertir de ascii a decimal
		mov  byte ah,[num1]
		mov byte al,[num1+1]
		call _wascii2dec


	;en al se encuentra el numero en decimal
	;alamcenar nota actual en un arreglo
	mov word bx,[contadorfilas]
	sub word bx,1d
	mov byte [todaslasnotas+rbx],al






	;verificar si ya se contaron todos las notas
	;es bubbletimes menor que contadorfilas
		mov word ax,[bubletimes]
		mov word bx,[contadorfilas]
		cmp  word ax,bx
		jg findnotes
		;limpiar contadorfilas para usarlo en el siguiente loop
		mov word [contadorfilas],0d




;------------------------contar cuantas notas existen por grupo de notas-----------------
;limpiar registro r10b, para ser utilizado como contador
mov byte r10b,0d

contarnotas:
		;cargar nota a comparar
		mov word bx,[contadorfilas]
		mov byte al,[todaslasnotas+rbx]
		;cargar nota a comparar
		mov byte bl,r10b
		mov byte dl,[arraynotas+rbx]
		;incrementar contador antes de saltar
		add byte r10b,1d
		;hacer comparacion
		cmp byte al,dl
		;salto
s1:		jg contarnotas

		;si pertenece a este grupo
		;incrementar el contador de notas en el grupo
		mov byte bl,r10b
		sub byte bl,1d
		mov byte al,[arrayestudiantes+rbx]
		add byte al,1d
		mov byte [arrayestudiantes+rbx],al
		;limpiar contador r10b
		mov byte r10b,0d
		;incrementar contadorfilas
		mov word ax,[contadorfilas]
		add word ax,1d
		mov word [contadorfilas],ax
		;verificar que contadorfilas sea menor a bubletimes
		mov word bx,[bubletimes]
		cmp word ax,bx
		;saltar
s2:		jb contarnotas


;limpiar contador r10b
	mov byte r10b,0d

;dividir 100 entre la cantidad total de datos
	mov byte al, 100
	mov byte bl,[bubletimes]
	div byte bl
	mov byte r9b,al  ;r9b almacena el resultado de la division
finalnotas:

;convertir a porcentajes los valores almacenados en arrayestudiantes

		;cargar dato
		mov byte bl,r10b
		mov byte al,[arrayestudiantes+rbx]
		; multiplicar dato por el resultado de dividir 100 entre la cantidad toal de estudiantes
		mul byte r9b
		;guardar resultado en la posicion actual
		mov byte [arrayestudiantes+rbx],al
		;incrementar contador
		add byte r10b,1d
		;comparar si ya se llego al final
		mov byte al,[bubletimes+1]
		cmp byte bl,al
		jb finalnotas


;---------------------------------------------Imprimir ---------------------------------
		;funcion que imprimi
		;mov rax, 1
		;mov rdi, 1
		;mov rsi, xx   ;aqui pongo lo que quiero imprimir
		;mov rdx, 14
		;syscall


;imprimir un enter por cuestiones esteticas
     mov rax, 1
     mov rdi, 1
     mov rsi, 10d
     mov rdx, 2
     syscall
;imprimir un  textordenado
     print textdat

;imprimir un enter por cuestiones esteticas
     mov rax, 1
     mov rdi, 1
     mov rsi, 10d
     mov rdx, 2
     syscall





;limpiar contador
	mov word [contadorfilas],1d
	mov word [sizef1],0d	;este contador se utilizara en el contador de columnas
loopimpresion:
xor rax,rax
xor rdx,rdx

;imprimir eje y

	mov word cx,[contadorfilas] ;carga el contador que indica que fila esta imprimiendo
	cmp word cx,1d		;compara si es la primera fila a imprimir
	jne continuarejey
	add word cx,1d
	mov word [contadorfilas],cx
	jmp loopimpresion
continuarejey:
	; si no es  la fila cero, entonces continua con la impresion normal del eje
	mov word bx,[canty]
	sub word bx,cx
	add word bx,1d
	mov byte al,[arrayaxisy+rbx]

;haciendo excepcion,si el numero supera el 100 se imprime un 100
	cmp byte al,100d
	jb nocien

;imprime el cien
	mov rax, 1
        mov rdi, 1
        mov rsi, cien
        mov rdx, 4
        syscall

	mov rax, 1
        mov rdi, 1
        mov rsi, finalfila
        mov rdx, 4
        syscall




	jmp imprimirx
nocien: mov byte al,[arrayaxisy+rbx]
	call _wdeci2ascii

;imprime las decenas
        mov rax, 1
        mov rdi, 1
        mov rsi, num1
        mov rdx, 1
        syscall


;imprime las unidades

        mov rax, 1
        mov rdi, 1
        mov rsi, num2
        mov rdx, 1
        syscall







; imprimir espacio

	mov rax, 1
        mov rdi, 1
        mov rsi, dobleespacio
        mov rdx, 2
        syscall


;imprimir indicativo de  inicio del grafico

        mov rax, 1
        mov rdi, 1
        mov rsi, finalfila
        mov rdx, 2
        syscall

        mov rax, 1
        mov rdi, 1
        mov rsi, dobleespacio
        mov rdx, 2
        syscall



;bucar donde imprimir x
imprimirx:
;cargar dato
	mov word bx,[sizef1]	;carga la posicion dentro del arreglo
	mov byte dl ,[arrayestudiantes+rbx]	;carga el dato para comparar
	mov word ax, [canty]		;carga el limite del loop
	sub word ax,[contadorfilas]	;calcula la posicion que actualmente va a imprimir
	mov byte bl,[arrayaxisy+rax]	;carga el dato a  <imprimir
	cmp byte dl,bl			;compara si debe o no imprimir una x en el histograma
	jb noprintx








	;compara si la x imprimir se encuentra antes de la nota de aprobacion
	;carga la nota de aprobacion
	mov byte ah,[nda]
	mov byte al,[nda+1]
	mov byte [num1],ah
	mov byte [num2],al
	;convierte la nota a decimal para poder comparar
	call _wascii2dec
bp4:	mov word bx,[sizef1]	;carga la posicion actual  en el arreglo de estudiantes
	mov byte cl,[arraynotas+rbx]
	;compara si la nota es menor a la nota de aprobacion
bp3:	cmp byte cl,al
	jg letrasverdes	; si es mayor a la nota de reposicion salta

	;si la nota es inferior a la nota de reposicion se compara para saber
	;si esta en el intervalo de la nota de reposicion o no
	;si este dato es menor que la nota de reposicion
	;se imprimen letras rojas
bp1:	mov byte ah,[ndr]
	mov byte al,[ndr+1]
	mov byte [num1],ah
	mov byte [num2],al

	call _wascii2dec
	mov word bx,[sizef1]
	mov byte cl,[arraynotas+rbx]
bp2:	cmp byte al,cl
	jb letrasamarillas

;se envia el comando a la pantalla para que cambie el color de la letra a impr$
        mov rax, 1
        mov rdi, 1
        mov rsi, rojo
        mov rdx, 5
        syscall


	jmp imprimircolor

letrasamarillas:

;se envia el comando a la pantalla para que cambie el color de la letra a impr$
        mov rax, 1
        mov rdi, 1
        mov rsi, amarillo
        mov rdx, 5
        syscall

	jmp imprimircolor


letrasverdes:

 ;se envia el comando a la pantalla para que cambie el color de la letra a imprimir
        mov rax, 1
        mov rdi, 1
        mov rsi, verde
        mov rdx, 5
        syscall














imprimircolor:

	;imprimir una x y el espacio
	mov rax, 1
	mov rdi, 1
	mov rsi, exis
	mov rdx, 2
	syscall

	;imprime 4 espacios con fin de dar un mejor formato al histograma
	mov rax, 1
        mov rdi, 1
        mov rsi, cuatroespacios
        mov rdx, 4
        syscall


	jmp compararx

noprintx:
	;si no se va a imprimir una x entonces se imprime dos espacios para mantener el formato

        mov rax, 1
        mov rdi, 1
        mov rsi, dobleespacio
        mov rdx, 2
        syscall

;imprime 4 espacios con fin de dar un mejor formato al histograma
        mov rax, 1
        mov rdi, 1
        mov rsi, cuatroespacios
        mov rdx, 4
        syscall


compararx:

;se envia el comando a la pantalla para que cambie el color de la letra a impr$
        mov rax, 1
        mov rdi, 1
        mov rsi, blanco
        mov rdx, 5
        syscall


	;comparar para saber si ya se llego al final de las columnas
	;incrementar el contador
	mov word ax,[sizef1]
	add word ax, 1d
	mov word [sizef1],ax
	;comparar
	cmp word ax,[cantx]
	;si es menor salta de nuevo al loop
	jb imprimirx

	; si no es menor limpia la variable sizef1
	mov word [sizef1],0d


 ;se imprime indicativo de final de linea
        mov rax, 1
        mov rdi, 1
        mov rsi, finalfila
        mov rdx, 1
        syscall


	;se imprime un enter
	mov rax, 1
        mov rdi, 1
        mov rsi, espacioyenter
        mov rdx, 2
        syscall




	;incrementa el contador de filas
	mov word ax,[contadorfilas]
	add word ax,1d
	mov word [contadorfilas],ax

	;Comparar si ya se llego al final de las filas
	mov word bx,[canty]
	add word bx,1d
	cmp word ax,bx
	jb loopimpresion	;si es menor vuelve al inicio del loop





;imprimir un enter por cuestiones esteticas del histograma
;imprime un doble espacio con fin de dar un mejor formato al histograma
        mov rax, 1
        mov rdi, 1
        mov rsi, espacioyenter
        mov rdx, 2
        syscall




;imprimir eje x

;dejar 4 espacio por no interferir en la columna con el eje y


        mov rax, 1
        mov rdi, 1
        mov rsi, cuatroespacios
        mov rdx, 4
        syscall

  mov rax, 1
        mov rdi, 1
        mov rsi, cuatroespacios
        mov rdx, 4
        syscall





;imprimir eje x
;limpia contador de filas
	mov word [contadorfilas],0d
imprimirejex:
	;cargar el dato a imprimir
	mov word bx,[contadorfilas]
	mov byte al,[arraynotas+rbx]
	;verificar que el numero no sea mayor a cien
	cmp  byte al, 100d
	jb nocien2
	;imprime un cien


        mov rax, 1
        mov rdi, 1
        mov rsi,cien
        mov rdx, 4
        syscall






	jmp finalhistograma


nocien2: mov byte al,[arraynotas+rbx]

	call _wdeci2ascii

;imprime las decenas
        mov rax, 1
        mov rdi, 1
        mov rsi, num1
        mov rdx, 1
        syscall
;imprime las unidades
        mov rax, 1
        mov rdi, 1
        mov rsi,num2
        mov rdx, 1
        syscall


;imprime 4 espacios
	mov rax, 1
        mov rdi, 1
        mov rsi,cuatroespacios
        mov rdx, 4
        syscall

;incrementa el contador
	mov word ax,[contadorfilas]
	add word ax,1d
	mov word [contadorfilas],ax

;verifica si ya se recorrio todo el eje
	cmp word ax,[cantx]
	jb imprimirejex


;aqui termina el histograma
finalhistograma:
;se imprime un enter y se acaba el programa

	mov rax, 1
        mov rdi, 1
        mov rsi,espacioyenter
        mov rdx, 2
        syscall







;imprime un doble espacio con fin de dar un mejor formato al histograma
        mov rax, 1
        mov rdi, 1
        mov rsi, dobleespacio
        mov rdx, 2
        syscall












	 .finalprograma: ; codigo para finalizar correctamente el programa
			; y solucionar el segmentation fault

			mov rax,60	;cargando la llamada 60d(sys_exit)
			mov rdi,0	;cargando 0 en rdi
			syscall		;llamando al sistema operativo



_wascii2dec:
	;convertir cada byte a decimal
	;num 1 es las decenas
	mov byte al, [num1]
	mov byte bl,[num2]
	sub byte al,48d
	sub byte bl,48d
	;multiplicar por 10 el primer numero
	mov byte cl,al
	add byte al,cl
        add byte al,cl
        add byte al,cl
        add byte al,cl
        add byte al,cl
        add byte al,cl
        add byte al,cl
        add byte al,cl
        add byte al,cl
	;ahora se le suma las unidades
	add byte al,bl
	ret

_wdeci2ascii:
		;recibe en al un byte en decimal y lo transforma a ascii
		;dividir el numero entre 10
		mov byte cl,al
		mov byte bl,10d
		div byte bl
		;resultado en al
		add byte al,48d
		mov byte [num1],al
		;calcular residuo
		sub byte al,48d
		mul byte bl
		sub byte cl,al
		add byte cl,48d
		mov byte [num2],cl
		ret
