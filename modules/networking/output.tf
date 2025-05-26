output "vpc" { 
    value = module.vpc
}

output "sg" { 
    value = { 
        lb = module.lb_sg.security_group
        web = module.web_sg.security_group
        db = module.db_sg.security_group
    }
}

# để truy cập vào modules này ta dùng cú pháp sau : module.<name>.<output_name>
# ví dụ muốn truy cập lb_sg ta dùng cú pháp sau : module.networking.sg.lb
# ví dụ muốn truy cập web_sg ta dùng cú pháp sau : module.networking.sg.web
# ví dụ muốn truy cập db_sg ta dùng cú pháp sau : module.networking.sg.db

