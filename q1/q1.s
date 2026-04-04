.globl make_node

# C code for make_node
# node* n = malloc(24);
# n->val = val;
# n->left = NULL;
# n->right = NULL;
# return n;

make_node:

    addi sp, sp, -16
    sd ra, 8(sp)

    mv t0, a0          # 1st arg i.e a0 has value so we save it in t0.

    li a0, 24          # we call malloc(24) which overwrites a0 so that it acts like a pointer in memory
    call malloc

    sw t0, 0(a0)       # we load t0(which is the value) into this memory and also use word because val only takes 4 bytes

    li t1, 0
    sd t1, 8(a0)       # left = NULL  
    sd t1, 16(a0)      # right = NULL

    ld ra, 8(sp)
    addi sp, sp, 16
    ret



# c logic for get function
# if (root == NULL) return NULL;
# if (root->val == val) return root;
# if (val < root->val) return get(root->left, val);
# else return get(root->right, val);

.globl get


get:
    addi sp, sp, -16
    sd ra, 8(sp)

    beqz a0, done          # if root == NULL, return NULL (a0 already 0)

    lw t1, 0(a0)           # t1 = root->val
    beq t1, a1, done       # if root->val == val, return root (a0 unchanged)
    blt a1, t1, go_left    # if val < root->val, go left
    j go_right             # else go right

go_left:
    ld a0, 8(a0)           # a0 = root->left
    call get
    j done

go_right:
    ld a0, 16(a0)          # a0 = root->right
    call get
    j done

done:
    ld ra, 8(sp)
    addi sp, sp, 16
    ret

#c logic for insert

# if (root == NULL) return make_node(val);
# if (val < root->val)
# root->left = insert(root->left, val);
# else if (val > root->val)
# root->right = insert(root->right, val);
# return root;


.globl insert

insert:
    addi sp, sp, -16
    sd ra, 8(sp)
    sd a0, 0(sp)

    beqz a0, new_insert        # if root == NULL, make a new node

    lw t1, 0(a0)               # t1 = root->val
    beq t1, a1, done_insert    # if equal return root
    blt a1, t1, insert_left    # if val < root->val, go left
    blt t1, a1, insert_right   # if val > root->val, go right

insert_left:
    ld a0, 8(a0)               # a0 = root->left
    call insert

    ld t2, 0(sp)               # restore og root
    sd a0, 8(t2)               # root->left = returned node

    mv a0, t2                  # return root
    j done_insert

insert_right:
    ld a0, 16(a0)              # a0 = root->right
    call insert

    ld t2, 0(sp)               # restore og root
    sd a0, 16(t2)              # root->right = returned node
    
    mv a0, t2                  # return root
    j done_insert

new_insert:
    mv a0, a1                  # a0 = val (argument to make_node)
    call make_node             # returns new node in a0

done_insert:
    ld ra, 8(sp)
    addi sp, sp, 16
    ret


# c logic for getAtMost

# int ans = -1;

# while (root != NULL) 
#    if (root->val <= val) {
#        ans = root->val;
#        root = root->right;
#    } else 
#        root = root->left;

# return ans;

.globl getAtMost

getAtMost:
    li t0, -1          # ans = -1

loop:

    beqz a1, done_getAtMost     # root == NULL

    lw t1, 0(a1)                # root->val

    ble t1, a0, getAtMost_right # go right

    ld a1, 8(a1)                # else just go left 
    j loop

getAtMost_right:

    mv t0, t1
    ld a1, 16(a1)      # go right
    j loop

done_getAtMost:

    mv a0, t0
    ret