import os, time

def main():
    srvcmd = '%s --set mapi_port=%s --dbinit "module(sql_server);module(pathfinder);module(mapi); sql_server_start(); pfstart(); mapi_start();"' % (os.getenv('MSERVER'),os.getenv('MAPIPORT'))
    srv = os.popen(srvcmd, 'w')
    time.sleep(10)                      # give server time to start
    cltcmd = os.getenv('MAPI_CLIENT')
    clt = os.popen(cltcmd, 'w')
    clt.close()
    srv.close()

main()
