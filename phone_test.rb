#"6154385000"
# "414-520-5000"
# "(941)979-2000"
# "650-799-0000"
# "613 565-4000"
# "778.232.7000"
# "(202) 328 1000"
# "530-919-3000"
# "8084974000"
# "858 405 3000"
# "14018685000"
# "315.450.6000"
# "510 282 4000"
# "787-295-0000"
# "9.82E+00"
# "(603) 305-3000"
# "530-355-7000"
# "206-226-3000"
# "607-280-2000"

def clear_homephone_number(homephone)
    homephone = homephone
    .gsub(/\D/,"")
    .gsub(/^1/, "")
    if homephone.length == 10 
        return homephone
    else 
        return "bad phone"
    end
end

puts clear_homephone_number("(603) 305-3000")