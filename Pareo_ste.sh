#!/bin/bash

##########################################################################################
#,_._._._._._._._._|__________________________________________________________,
#|_|_|_|_|_|_|_|_|_|_________________________________________________________/
#                  !
#                        Fabian Vergara - Allware 2019
##########################################################################################
#Pareo Base suscritos de un proveedor VS suscritos STE
#para la ejecucion se debe tener la base de moviles suscritos del proveedor y la lista.
#la base se pasa como parametro al script para que realice el pareo
#Ej: sh script.sh base.txt
##########################################################################################
HOST_BD='192.168.33.176'
USER_BD='ste'
PASS_BD='ste321'
ARCHIVO=$1
DATE=`date +'%Y%m%d'`

RUTA_RESULTADO='/home/vas/fvergara/pareos/resultados'
RUTA_TMP='/home/vas/fvergara/pareos/tmp'
RUTA='/home/vas/fvergara/pareos/script'

if [ -f "${ARCHIVO}" ];then
        echo "Ingrese lista para pareo:"
        read lista;
        else
        echo "Se debe entregar la base con msisdn como parametro ejemplo:"
        echo "./script.sh base.txt"
        exit

fi
QUERY="select element from TBL_LIST_ELEMENTS where id_list='${lista}'"

#Obtiene base de lista en BD
mysql -h${HOST_BD} -u${USER_BD} -p${PASS_BD} STE -N -e "${QUERY}" | sort | uniq > ${RUTA_TMP}/Base_ste_${lista}.txt

###########################################################
## - PAREO -
###########################################################

#Ordeno y unifico archivo de msisdn del proveedor
sort ${ARCHIVO} |uniq > ${ARCHIVO}.sort
#cruso bases para encontrar las coincidencias
join ${ARCHIVO}.sort ${RUTA_TMP}/Base_ste_${lista}.txt > ${RUTA_RESULTADO}/TOTAL_PROVEEDOR_STE_${DATE}.txt
#obtengo solo los msisdn que estan en base STE
join -v2 ${ARCHIVO}.sort ${RUTA_TMP}/Base_ste_${lista}.txt > ${RUTA_RESULTADO}/TOTAL_SOLO_STE_${DATE}.txt
#Obtengo los msisdn que solo estan en base del Proveedor
join -v1 ${ARCHIVO}.sort ${RUTA_TMP}/Base_ste_${lista}.txt > ${RUTA_RESULTADO}/TOTAL_SOLO_PROVEEDOR_${DATE}.txt


##Obtengo los valores totales de las bases de resultado.
Q_STE=`wc -l ${RUTA_TMP}/Base_ste_${lista}.txt | awk '{print $1}'`
Q_PROVEEDOR=`wc -l ${ARCHIVO}.sort | awk '{print $1}'`
Q_PROVEEDOR_STE=`wc -l ${RUTA_RESULTADO}/TOTAL_PROVEEDOR_STE_${DATE}.txt | awk '{print $1}'`
Q_SOLO_STE=`wc -l ${RUTA_RESULTADO}/TOTAL_SOLO_STE_${DATE}.txt | awk '{print $1}'`
Q_SOLO_PROVEEDOR=`wc -l  ${RUTA_RESULTADO}/TOTAL_SOLO_PROVEEDOR_${DATE}.txt | awk '{print $1}'`

## Imprimo resumen de datos obtenidos en cruce.
echo "STE: $Q_STE"
echo "PROVEEDOR: $Q_PROVEEDOR"
echo "STE y MOVIX: $Q_PROVEEDOR_STE"
echo "SOLO STE: $Q_SOLO_STE"
echo "SOLO MOVIX: $Q_SOLO_PROVEEDOR"
