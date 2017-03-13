#!/bin/bash
############################################
#           mysql���Թ���         
#
#2014-04-18 by ����
#version:1.0
#ʹ�÷�����
#����./mysqltest.sh
#
############################################

mysql_path_check()
{
	which mysql 2>/dev/null && mysql_path=$(which mysql|head -1) || read -p "������mysql·�����磺/usr/local/mysql/bin/mysql :" mysql_path
	if [ ! -e "${mysql_path}" ];then
		echo "mysql·���������ʵ"
		exit
	fi
}

input_info()
{
	clear
	#�û���
	read -p "������mysql�û�����������Ĭ��Ϊroot :" username
	stty -echo
	read -p "������mysql���� :" password
	stty echo
	echo ""
	read -p "������mysql������ַ��������Ĭ��Ϊlocalhost :" hostname
	read -p "������mysql�˿ڣ�������Ĭ��Ϊ3306 :" port
	mysql_connect="${mysql_path} -u${username:=root} -p${password:=password} -h${hostname:=localhost} -P${port:=3306}"
	${mysql_connect} -e 'show databases' >/dev/null || { echo "����ʧ��" ;exit;}
}

list_table()
{
	clear
	mysql_db=$(${mysql_connect} -Ns -e 'show databases'|grep -E -v -w "information_schema|mysql|performance_schema")
	echo "��ѡ�����ݿ�:"
	select database in $mysql_db
	do
		break
	done
	echo "���ݿ�:$database �е����ݱ�:"
	${mysql_connect} -D$database -e 'show tables'
}

show_session()
{
	${mysql_connect} -N -e "select id,user,host,db,command,time,state,info from information_schema.processlist where info not like '%information_schema.processlist%'"	
}

count_session()
{
	${mysql_connect} -e "select user,count(user) as count_session from information_schema.processlist group by user order by count_session desc"
}

check_privilege()
{
	${mysql_connect} -e "select host,user,Select_priv, Insert_priv, Update_priv, Delete_priv, Create_priv, Drop_priv from mysql.user"
}


select_fn()
{
	echo -e "\n��ѡ����:"
	select fn in "��ʾ���ݱ�" "��ʾ�������б�" "������ͳ��" "Ȩ�޲�ѯ(��root�˺�)" "�������Ա�" "ɾ�����Ա�" "�˳�"
	do
		break
	done
	case $fn in
	��ʾ���ݱ�)
		list_table
		;;
	��ʾ�������б�)
		show_session
		;;
	������ͳ��)
		count_session
		;;
	Ȩ�޲�ѯ\(��root�˺�\))
		check_privilege
		;;
	�������Ա�)
		create_table
		;;
	ɾ�����Ա�)
		drop_table
		;;
	�˳�)
		exit
	esac
}

create_table()
{
	if [ -n "$database" ];then
		${mysql_connect} -D$database -e "CREATE TABLE $database.test_script_table (name varchar(15) NOT NULL,age int(15) NOT NULL, createTime datetime DEFAULT NULL,PRIMARY KEY (name)) ENGINE=InnoDB DEFAULT CHARSET=utf8;" && echo "���Ա�: test_script_table ���� $database ���д����ɹ�,��ʹ��\"��ʾ���ݱ�\"���ܲ鿴" || echo "�������Ա�ʧ��"
	else
		echo "����ѡ��\"��ʾ���ݱ�\"����"
	fi
}

drop_table()
{
	if [ -n "$database" ];then
		${mysql_connect} -D$database -e "DROP TABLE $database.test_script_table" && echo "���Ա�: test_script_table �Ѵ� $database ����ɾ���ɹ�,��ʹ��\"��ʾ���ݱ�\"���ܲ鿴" || echo "ɾ�����Ա�ʧ��"
	else
		echo "����ѡ��\"��ʾ���ݱ�\"����"
	fi
}

mysql_path_check
input_info
while true
do
	select_fn
done
