# PRのタイトルにIssue番号が含まれているか（#数字の塊 タイトル）
isTitleFormat = github.pr_title.match(/^#\d{1,}/)
fail("PRのタイトルは#&lt;Issue番号&gt;から始めてください。") unless isTitleFormat

# マージできないラベルがついているか
failure "WIPがついているため、マージしないように" if github.pr_labels.include? "WIP"

# featureブランチはmasterブランチにマージさせない
isFeature = github.branch_for_head.match(/feature\//)
if isFeature && github.branch_for_base == "master"
   fail("featureはmasterブランチにマージできません")
end

# Swiftformat
swiftformat.check_format(fail_on_error: true)
