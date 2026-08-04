# Exercises the standalone osl_postfix_server path: no prior osl_postfix
# baseline call. The resource should auto-declare the inner postfix
# resource via osl_postfix_ensure_inner_resource and converge in master
# mode end-to-end.
osl_postfix_server 'default'
