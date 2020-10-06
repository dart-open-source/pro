


String tempCli='''
#!/bin/bash
#head#
nohup dart "\$1" "\$2" > "\$3.log" 2>&1 &
''';