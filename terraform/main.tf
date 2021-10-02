# Define role which can be assumed by any user in the same account
data "aws_iam_policy_document" "assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.aws_account}:root"]
    }
  }
}

resource "aws_iam_role" "ci-role" {
  name               = "${var.prefix}-ci-role"
  assume_role_policy = data.aws_iam_policy_document.assume-role-policy.json
}


# Policy, allowing users / entities to assume the above role
data "aws_iam_policy_document" "role_custom_assume_role" {
  statement {
    effect = "Allow"
    actions   = [
      "iam:GetRole",
      "sts:AssumeRole"
    ]
    resources = ["*"]
  }
}

# A group, with the above policy attached
resource "aws_iam_group" "ci-group" {
  name = "${var.prefix}-ci-group"
}

resource "aws_iam_group_policy" "ci-group-assume-policy" {
  name   = "${var.prefix}-ci-group-assume-policy"
  group  = aws_iam_group.ci-group.name
  policy = data.aws_iam_policy_document.role_custom_assume_role.json
}

# A user, belonging to the above group
resource "aws_iam_user" "ci-user" {
  name = "${var.prefix}-ci-user"
}

resource "aws_iam_user_group_membership" "ci-user-group-membership" {
  user = aws_iam_user.ci-user.name

  groups = [
    aws_iam_group.ci-group.name,
  ]
}
