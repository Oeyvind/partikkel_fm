
import sys
import subprocess
import concurrent.futures
pool = concurrent.futures.ThreadPoolExecutor(max_workers=25)

datasets = [
  'small',
  'zoom_valley_gd_ndx_dly300_gp_500', 
  'zoom_simple_gd_ndx_dly065_gp310', 
  'zoom_simple_gd_ndx_dly165_gp310' 
]
#  'full',
#  'zoom_promonotory_gd_ndx_dly010_gp700'



def action(d, mode):
  if mode == 'generate':
    err = subprocess.run(f'python generate_and_analyze.py {d} csound')
    err = subprocess.run(f'python display.py {d} analyze')
  if mode == 'display':
    err = subprocess.run(f'python display.py {d} saved')  
    print(err)

for d in datasets:
  pool.submit(action, d, 'generate')

