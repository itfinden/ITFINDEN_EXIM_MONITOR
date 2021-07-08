#!/bin/bash


#Detectando cuantos correos hay en cola..

strContador=$(/usr/sbin/exim -bpc)
if [ $strContador -gt 500 ]
then
	#captura las ultimas 50 lineas de exim

	rm -rf /root/ITFINDEN/log/detectaspam.txt
	tail -n 50 /var/log/exim_mainlog >> /root/ITFINDEN/log/detectaspam.txt

	#capturando correo desde el log

	rm -rf /root/ITFINDEN/log/detectaspam-2.txt
	cat /root/ITFINDEN/log/detectaspam.txt|grep dovecot_login|awk '{print $5}' >> /root/ITFINDEN/log/detectaspam-2.txt
	rm -rf /root/ITFINDEN/log/detectaspam-3.txt
	grep '@' /root/ITFINDEN/log/detectaspam-2.txt | gawk '{print $1}' | sort | uniq -d >> /root/ITFINDEN/log/detectaspam-3.txt

	#generando el cambio de contraseña

	#contraseña 0gEc}zSAvcw[ encriptada
	#pass=:$1$jJmvfZwX$WCyxZ8ohlPppxbvQ4.Osy1:15549::::::

	#leyendo archivo que tiene contraseña
		DBS=`cat /root/ITFINDEN/clavemail`
			for pass in $DBS ;
			do
			echo
		done

	#descubriendo el dominio que tiene la cuenta infectada
		DBS=`cat /root/ITFINDEN/log/detectaspam-3.txt| awk -F@ '{print $(NF-0)}'`
			for a in $DBS ;
			do
			echo
		done

	rm -rf /root/ITFINDEN/log/detectaspam-4.txt
	cat /etc/trueuserdomains|grep "$a" >> /root/ITFINDEN/log/detectaspam-4.txt

	#descubriendo el usuario del cpanel y trabajando en el archivo shadow
	DBS=`cat /root/ITFINDEN/log/detectaspam-3.txt| awk -F@ '{print $(NF-1)}'`
		for ucorreo in $DBS ;
		do
		echo
		done

	DBS=`cat /root/ITFINDEN/log/detectaspam-4.txt| awk '{print $2}'`
	for b in $DBS ;
	do
	echo
	done

	#eliminando la cuenta en el archivo shadow
	/bin/sed -i "/$ucorreo/ d" /home/"$b"/etc/"$a"/shadow

	#agregando la cuenta en el archivo shadow
	echo "$ucorreo"$pass >> /home/"$b"/etc/"$a"/shadow

	#enviando alerta a los correos corporativos :D

	TEMPFILE=/root/ITFINDEN/log/cambioclave.txt
	rm -rf $TEMPFILE
	Host=`hostname`
	Asunto="En el servidor $Host se ha detectado una cuenta infectada"
	echo "*****************************************************************************" >> $TEMPFILE
	echo ""                                                                              >> $TEMPFILE
	echo "Correos en cola:"                                                              >> $TEMPFILE
	echo ""                                                                              >> $TEMPFILE
	/usr/sbin/exim -bpc                                                                  >> $TEMPFILE
	echo "Se ha designado la clave 0gEc}zSAvcw[ al siguiente correo: "                   >> $TEMPFILE
	echo ""                                                                              >> $TEMPFILE
	cat /root/ITFINDEN/log/detectaspam-3.txt                           >> $TEMPFILE
	echo ""                                                                              >> $TEMPFILE
	echo "*****************************************************************************" >> $TEMPFILE
	echo "Saludos Bot de monitoreo ITFINDEN :)"                                          >> $TEMPFILE
	mail -s "$Asunto" $(/bin/cat -- /root/ITFINDEN/.envios3) < $TEMPFILE
	
	#eliminando la cola de mails
		#rm -rf /var/spool/exim/input/*
	
	#reiniciando exim
	/sbin/service exim restart
else
	echo "funciona?"
fi
