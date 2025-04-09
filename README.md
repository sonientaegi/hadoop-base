# hadoop-base
하둡 베이스 이미지

## 스펙 및 설정
- hadoop 3.4.1
- openJDK-11
- 도커 네트워크 : hadoop
- 네임노드 : nn
- 데이터노드 : dn0, dn1, dn2

## 클러스터 생성
```shell
docker build --tag hadoop-base .
docker network create hadoop
docker run -itd --name dn0 -h dn0 --network hadoop -p 9864:9864 hadoop-base
docker run -itd --name dn1 -h dn1 --network hadoop -p 9865:9864 hadoop-base
docker run -itd --name dn2 -h dn2 --network hadoop -p 9866:9864 hadoop-base
docker run -itd --name nn -h nn --network hadoop -p 9870:9870 -p 9820:9820 hadoop-base
```

## 하둡 초기화
```shell
docker exec -it nn /bin/bash
hdfs namenode -format
hdfs datanode -format
```

## 하둡 실행 확인
- jps
- http://localhost:9870

## 설정 변경
워커 노드 개수 변경을 포함한 수정사항 발생시 workers, core-site.xml, hdfs-site.xml 파일을 변경후 다시 빌드를 한다.